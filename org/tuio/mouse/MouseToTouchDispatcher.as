package org.tuio.mouse
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenuItem;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import org.tuio.*;
	import org.tuio.debug.*;
	import org.tuio.fiducial.FiducialEvent;
	import org.tuio.fiducial.TuioFiducialDispatcher;
	import org.tuio.util.DisplayListHelper;

	/**
	 * Listens on MouseEvents, "translates" them to the analog TouchEvents and FiducialEvents and dispatches
	 * them on <code>DisplayObject</code>s under the mouse pointer.
	 * 
	 * Additionally, it provides means to simulate multi-touch input with a single mouse.
	 * By pressing the 'Shift' key a touch can be added permanently. By pressing the 'Ctrl'
	 * in Windows or the 'Command' key in Mac OS X a touch will be added to a group. Furthermore,
	 * object interaction can be simulated by choosing a fiducial id from the context menu and
	 * manipulating the debug representation of the fiducial subsequently. It can be dragged around
	 * or if 'r' is pressed it can be rotated. If 'Shift' is pressed a fiducial will be removed.
	 * 
	 * A group of touches will be moved around together. To rotate a group of touches, press
	 * the 'r' key, while dragging. To make a group disappear after dragging hold the 'Space'
	 * key while dragging. This is very handy, if you want to test physical properties of an
	 * object like inertia around an angle. This is not possible e.g. with the Tuio Simulator
	 * or SimTouch. 
	 * 
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 * @see org.tuio.TouchEvent
	 * 
	 */
	public class MouseToTouchDispatcher
	{
		private var stage:Stage;
		private var useTuioManager:Boolean;
		private var useTuioDebug:Boolean;
		private var tuioSessionId:uint;
		private var touchMoveId:Number;
		private var movedObject:ITuioDebugObject;
		private var shiftKey:Boolean;
		private var groups:Dictionary;
		
		private var frameId:uint = 0;
		private var lastX:Number;
		private var lastY:Number;
		
		private var spaceKey:Boolean;
		private var rKey:Boolean;
		private var rotationMouseX:Number;
		private var rotationMouseY:Number;
		
		private var fiducialContextMenu:ContextMenu;
		
		private const TWO_D_CUR:String = "2Dcur";
		private const TWO_D_OBJ:String = "2Dobj";
		
		/**
		 * initializes MouseToTouchDispatcher by adding appropriate event listeners to it. Basically, MouseToTouchDispatcher
		 * listens on mouse events and translates them to touches. However, additionally keyboard listeners are being added
		 * that listen on keyboard events to control certain actions like rotation of a touches group by holding 'r'.
		 * 
		 * @param stage 
		 * @param useTuioManager call the add, move and remove functions of the TuioManager instead of simply dispatching TouchEvents. You have to initialize TuioManager before.
		 * @param useTuioDebug show the touches as debug cursors. You have to initialize TuioDebug before.
		 * 
		 */
		public function MouseToTouchDispatcher(stage:Stage, useTuioManager:Boolean = true, useTuioDebug:Boolean = true)
		{
			this.stage = stage; 
			enableDispatcher();
			
			this.useTuioManager = useTuioManager; 
			this.useTuioDebug = useTuioDebug;
			
			//descend through uint from the highest number
			tuioSessionId = 0-1;
			touchMoveId = tuioSessionId;
			
			lastX = stage.mouseX;
			lastY = stage.mouseY;
			
			groups = new Dictionary();
			
			spaceKey = false;
			rKey = false;
			rotationMouseX = 0;
			rotationMouseY = 0;
			
			createContextMenu();
		}
		
		public function enableDispatcher():void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, contextMenuClick);
		}
		
		public function disableDispatcher():void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.removeEventListener(MouseEvent.RIGHT_CLICK, contextMenuClick);
		}
		
		/**
		 * If there is no existing touch 
		 * under the mouse pointer, a new touch will be added. However, if there already is one it will be marked
		 * for movement and no new touch is being added. Alternatively, if there is a fiducial underneath the mouse 
		 * pointer it will be selected for movement. If the 'Shift' key is pressed and there is an 
		 * existing touch beneath the mouse cursor this touch will be removed. Alternatively, If the 'Shift' key is pressed
		 * and there is a fiducial underneath the mouse pointer, the fiducial will be removed. 
		 * 
		 * If the 'Ctrl/Command' key is pressed 
		 * the touch will be added to a group (marked by a dot in the center of a touch) if it does not belong to a 
		 * group already. If it does it will be removed from the group.
		 * 
		 * NOTE: Adding touches permanently does only work if TuioDebug is being used and useTuioDebug is switched on.
		 *  
		 * @param event
		 * 
		 */
		private function handleMouseDown(event:MouseEvent):void{
			var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(event.stageX, event.stageY); 
			var objectUnderPoint:ITuioDebugObject = getObjectUnderPointer(event.stageX, event.stageY);
			
			if(cursorUnderPoint != null){
				startMoveCursor(cursorUnderPoint, event);
			}else if(objectUnderPoint != null){
				startMoveObject(objectUnderPoint, event);
			}else{
				//add new mouse pointer
				var frameId:uint = this.frameId++;	
				var tuioContainer:TuioContainer = createTuioContainer(TWO_D_CUR, event.stageX,event.stageY, this.tuioSessionId, frameId);
				
				//standard
				if(this.useTuioManager){
					TuioManager.getInstance().handleAdd(tuioContainer);
				}else{
					var stagePos:Point = new Point(event.stageX, event.stageY);
					var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
					var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
					
					target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				}
				if(this.useTuioDebug){
					var cursor:TuioCursor = createTuioCursor(event.stageX, event.stageY, this.tuioSessionId, frameId);
					TuioDebug.getInstance().addTuioCursorWithDebugOption(cursor, true);
				}
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
				
				//takes care that the cursor will not be removed on mouse up
				this.shiftKey = event.shiftKey;
			}
		}
		
		//==========================================  CONTEXT MENU STUFF ==========================================  
		/**
		 * 
		 * creates a context menu with 100 context menu items that allows to choose
		 * to add a debug fiducial with the fiducialId of the chosen menu item. 
		 */
		private function createContextMenu():void{
			fiducialContextMenu = new ContextMenu();
			
			for(var i:Number = 0; i < 100; i++){
				var item:NativeMenuItem = new NativeMenuItem("Add Fiducial "+i);
				fiducialContextMenu.addItem(item);
				item.addEventListener(Event.SELECT, contextMenuSelected); 
			}
		}
		
		/**
		 * shows the context menu
		 *  
		 * @param event mouse event.
		 * 
		 */
		private function contextMenuClick(event:MouseEvent):void{
			fiducialContextMenu.display(stage, event.stageX, event.stageY);
		}
		
		/**
		 * adds a debug fiducial with the fiducialId of the chosen menu item to the stage.
		 *  
		 * @param event
		 * 
		 */
		private function contextMenuSelected(event:Event):void{
			var itemLabel:String = (event.target as NativeMenuItem).label;
			var fiducialId:Number = int(itemLabel.substring(itemLabel.lastIndexOf(" ")+1, itemLabel.length));
			this.tuioSessionId = this.tuioSessionId-1;
			dispatchAddFiducial(stage.mouseX, stage.mouseY, fiducialId);
		}
		
		/**
		 * 
		 * @param stageX x position of mouse 
		 * @param stageY y position of mouse
		 * @param fiducialId chosen fiducialId
		 * 
		 */
		private function dispatchAddFiducial(stageX:Number, stageY:Number, fiducialId:uint):void{
			var frameId:uint = this.frameId++;	
			var tuioObject:TuioObject = createTuioObject(fiducialId, stageX,stageY, this.tuioSessionId, 0, frameId); 
			
			//standard
			if(this.useTuioManager){
				TuioManager.getInstance().addTuioObject(tuioObject);
				TuioFiducialDispatcher.getInstance().addTuioObject(tuioObject);
			}else{
				var stagePos:Point = new Point(stageX, stageY);
				var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
				var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
				
				target.dispatchEvent(new FiducialEvent(FiducialEvent.ADD, local.x, local.y, stagePos.x, stagePos.y, target, tuioObject));
			}
			if(this.useTuioDebug){
				TuioDebug.getInstance().addTuioObjectWithDebugOption(tuioObject, true);
			}
		}
		
		//==========================================  TOUCH STUFF ==========================================
		
		/**
		 * decides whether a TUIO debug cursor should be removed, added to a cursor group or it should be moved around.
		 * 
		 * @param cursorUnderPoint TUIO debug cursor under the mouse pointer.
		 * @param event
		 * 
		 */
		private function startMoveCursor(cursorUnderPoint:ITuioDebugCursor, event:MouseEvent):void{
			//update or remove cursor under mouse pointer
			if(event.shiftKey){
				//remove cursor
				removeCursor(event, cursorUnderPoint.sessionId);
				deleteFromGroup(cursorUnderPoint);
			}else if(event.ctrlKey){
				var cursorObject:Object = this.groups[cursorUnderPoint.sessionId];
				
				//add cursor to group
				if(cursorObject == null){
					//add to group
					addToGroup(cursorUnderPoint);
				}else{
					//remove from group
					(cursorObject.cursor as DisplayObjectContainer).removeChild(cursorObject.markerSprite);
					//						delete this.groups[cursorUnderPoint.sessionId];
					deleteFromGroup(cursorUnderPoint);
				}
			}else{
				//move cursor
				this.touchMoveId = cursorUnderPoint.sessionId;
				
				//take care that cursor is moved around the middle
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
			}
		}
		
		/**
		 *adds a cursor to a group.
		 *  
		 * @param cursorUnderPoint the cursor that should be added to the group.  
		 * 
		 */
		private function addToGroup(cursorUnderPoint:ITuioDebugCursor):void{
			var cursorObject:Object = this.groups[cursorUnderPoint.sessionId];
			
			cursorObject = new Object();
			cursorObject.cursor = cursorUnderPoint;
			
			var markerSprite:Sprite = new Sprite();
			markerSprite.graphics.beginFill(0xff0000);
			markerSprite.graphics.drawCircle(0,0,3);
			markerSprite.graphics.endFill();
			(cursorUnderPoint as DisplayObjectContainer).addChild(markerSprite);
			
			cursorObject.markerSprite = markerSprite;
			
			this.groups[cursorUnderPoint.sessionId] = cursorObject;
		}
		
		/**
		 * deletes a cursor from the group dictionary.
		 *  
		 * @param cursorUnderPoint the cursor that should be removed from the group.
		 * 
		 */
		private function deleteFromGroup(cursorUnderPoint:ITuioDebugCursor):void{
			delete this.groups[cursorUnderPoint.sessionId];
		}
		
		/**
		 * moves a touch. 
		 * 
		 * If the 'r' key is being pressed and a touch that is member of a group is being 
		 * moved around the group will be rotated around its berycentric point. To rotate the touches, 
		 * drag the mouse left and right.
		 *  
		 * @param event
		 * 
		 */
		private function dispatchTouchMove(event:MouseEvent):void{
			if(this.groups[this.touchMoveId] != null){
				var xDiff:Number =  stage.mouseX-this.lastX;
				var yDiff:Number = stage.mouseY-this.lastY;
				
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				var cursorObject:Object;
				var cursor:DisplayObjectContainer
				
				var xPos:Number;
				var yPos:Number;
				
				//simply move grouped touches if 'r' key is not pressed
				if(!this.rKey){
					for each(cursorObject in this.groups){
						cursor = cursorObject.cursor as DisplayObjectContainer;
						xPos = cursor.x + xDiff;
						yPos = cursor.y + yDiff;
						moveCursor(xPos, yPos, cursorObject.cursor.sessionId);
					}
				}else{
					//rotate grouped touches if 'r' key is pressed
					for each(cursorObject in this.groups){
						cursor = cursorObject.cursor as DisplayObjectContainer;
						
						var cursorMatrix:Matrix = cursor.transform.matrix;
						cursorMatrix.translate(-this.rotationMouseX, -this.rotationMouseY);
						cursorMatrix.rotate(0.01 * -yDiff);
						cursorMatrix.translate(this.rotationMouseX, this.rotationMouseY);
						xPos = cursorMatrix.tx;
						yPos = cursorMatrix.ty;
						moveCursor(xPos, yPos, cursorObject.cursor.sessionId);
					}
				}
			}else{
				//if no touch from group has been select simply move single touch
				moveCursor(stage.mouseX, stage.mouseY, this.touchMoveId);				
			}
		}
		
		/**
		 * takes care of the touch movement by dispatching an appropriate TouchEvent or using the TuioManager and 
		 * adjusts the display of the touch in TuioDebug.
		 *  
		 * @param stageX the x coordinate of the touch 
		 * @param stageY the y coordinate of the touch 
		 * @param sessionId the session id of the touch 
		 * 
		 */
		private function moveCursor(stageX:Number, stageY:Number, sessionId:uint):void{
			var frameId:uint = this.frameId++;
			var tuioContainer:TuioContainer = createTuioContainer(TWO_D_CUR, stageX, stageY, sessionId, frameId);
			
			if(this.useTuioManager){
				TuioManager.getInstance().handleUpdate(tuioContainer);
			}else{
				var stagePos:Point = new Point(stageX, stageY);
				var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
				var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
				
				target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			if(this.useTuioDebug){
				var cursor:TuioCursor = createTuioCursor(stageX, stageY, sessionId, frameId);
				TuioDebug.getInstance().updateTuioCursorWithDebugOption(cursor, true);
			}
		}
		
		/**
		 * removes the touch that is being dragged around from stage if no key has been pressed.
		 * 
		 * If the 'Shift' key has been pressed the touch will remain on the stage. 
		 * 
		 * If the 'Ctrl/Command' key has been pressed the touch will remain on stage and will be 
		 * added to a group.
		 * 
		 * If the 'Space' key is being pressed and a group of touches is being moved around the 
		 * whole group of touches will be removed.
		 *   
		 * @param event
		 * 
		 */
		private function dispatchTouchUp(event:MouseEvent):void{
			if(this.groups[this.touchMoveId] == null){
				//keep touch if shift key has been pressed
				if(!this.shiftKey && !event.ctrlKey){
					removeCursor(event, tuioSessionId);
				}else if(event.ctrlKey){
					var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(event.stageX, event.stageY);
					addToGroup(cursorUnderPoint);
				}
			}else{
				if(this.spaceKey){
					//remove all touches from group if space key is pressed
					for each(var cursorObject:Object in this.groups){
						var cursor:DisplayObjectContainer = cursorObject.cursor as DisplayObjectContainer;
						removeCursor(event, cursorObject.cursor.sessionId);
						deleteFromGroup(cursorObject.cursor);
					}
				}
			}
			
			tuioSessionId = tuioSessionId-1;
			touchMoveId = tuioSessionId;
			
			lastX = 0;
			lastY = 0;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
		}
		
		/**
		 * removes a touch from stage by dispatching an appropriate TouchEvent or using the TuioManager and 
		 * removes the display of the touch in TuioDebug.
		 *  
		 * @param event
		 * @param sessionId session id of touch
		 * 
		 */
		private function removeCursor(event:MouseEvent, sessionId:uint):void{
			var frameId:uint = this.frameId++;
			if(this.useTuioManager){
				TuioManager.getInstance().handleRemove(createTuioContainer(TWO_D_CUR, event.stageX, event.stageY, sessionId, frameId));
			}else{
				var stagePos:Point = new Point(event.stageX, event.stageY);
				var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
				var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
				
				target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(TWO_D_CUR, event.stageX, event.stageY, sessionId, frameId)));
			}
			
			if(this.useTuioDebug){
				TuioDebug.getInstance().removeTuioCursor(createTuioCursor(event.stageX, event.stageY, sessionId, frameId));
			}	
		}
		/**
		 * returns the touch under the mouse pointer if there is one. Otherwise null will be returned.
		 * If the mouse pointer is above the red dot of a touch that beloings to a group still the
		 * touch will be returned.
		 *   
		 * @param stageX
		 * @param stageY
		 * @return the touch under the mouse pointer if there is one. Otherwise null will be returned.
		 * 
		 */
		private function getCursorUnderPointer(stageX:Number, stageY:Number):ITuioDebugCursor{
			var cursorUnderPointer:ITuioDebugCursor = null;
			
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(new Point(stageX, stageY));
			
			if(objectsUnderPoint[objectsUnderPoint.length-1] is ITuioDebugCursor){
				cursorUnderPointer = objectsUnderPoint[objectsUnderPoint.length-1];
			}else if(objectsUnderPoint.length > 1 && objectsUnderPoint[objectsUnderPoint.length-2] is ITuioDebugCursor){
				//if mouse pointer is above marker sprite, return ITuioDebugCursor beneath marker sprite
				cursorUnderPointer = objectsUnderPoint[objectsUnderPoint.length-2];
			}
			
			return cursorUnderPointer; 
		}
		
		
		/**
		 * 
		 * @param stageX
		 * @param stageY
		 * @return 
		 * 
		 */
		private function getObjectUnderPointer(stageX:Number, stageY:Number):ITuioDebugObject{
			var objectUnderPointer:ITuioDebugObject = null;
			
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(new Point(stageX, stageY));
			
			if(objectsUnderPoint[objectsUnderPoint.length-1] is ITuioDebugObject){
				objectUnderPointer = objectsUnderPoint[objectsUnderPoint.length-1];
			}else if(objectsUnderPoint.length > 1 && objectsUnderPoint[objectsUnderPoint.length-2] is ITuioDebugObject){
				//if mouse pointer is above marker sprite, return ITuioDebugCursor beneath marker sprite
				objectUnderPointer = objectsUnderPoint[objectsUnderPoint.length-2];
			}
			
			return objectUnderPointer; 
		}

		/**
		 * created a TuioCursor instance from the submitted parameters.
		 *  
		 * @param stageX an x coordinate in global coordinates.
		 * @param stageY a y coordinate in global coordinates.
		 * @param touchId the session id of a touch.
		 * 
		 * @return the TuioCursor.
		 * 
		 */
		private function createTuioCursor(stageX:Number, stageY:Number, sessionId:uint, frameId:uint):TuioCursor{
			return new TuioCursor(TWO_D_CUR,sessionId,stageX/stage.stageWidth, stageY/stage.stageHeight,0,0,0,0,0,frameId);
		}
		
		/**
		 * created a TuioContainer instance from the submitted parameters.
		 *  
		 * @param stageX an x coordinate in global coordinates.
		 * @param stageY a y coordinate in global coordinates.
		 * @param touchId the session id of a touch.
		 * 
		 * @return the TuioContainer.
		 * 
		 */
		private function createTuioContainer(type:String, stageX:Number, stageY:Number, sessionId:uint, frameId:uint):TuioContainer{
			return new TuioContainer(type,sessionId,stageX/stage.stageWidth, stageY/stage.stageHeight,0,0,0,0,0,frameId);
		}
		
		
		//==========================================  FIDUCIAL STUFF ==========================================
		
		/**
		 * decides whether a TUIO debug object should be removed or moved around.
		 * 
		 * @param cursorUnderPoint TUIO debug object under the mouse pointer.
		 * @param event
		 * 
		 */
		private function startMoveObject(objectUnderPoint:ITuioDebugObject, event:MouseEvent):void{
			//update or remove cursor under mouse pointer
			if(event.shiftKey){
				//remove cursor
				removeObject(event);
			}else{
				//move cursor
				this.movedObject = objectUnderPoint;
				
				//store start position in order to move object around the point where it has been clicked
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchObjectMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchObjectUp);
			}
		}
		
		/**
		 * moves a fiducial. 
		 * 
		 * If the 'r' key is being pressed the TUIO object will be rotated.
		 *  
		 * @param event
		 * 
		 */
		private function dispatchObjectMove(event:MouseEvent):void{
			var stageX:Number = (this.movedObject as DisplayObjectContainer).x + stage.mouseX - this.lastX;
			var stageY:Number = (this.movedObject as DisplayObjectContainer).y + stage.mouseY - this.lastY;
			if(!this.rKey){
				moveObject(stageX, stageY, this.movedObject.sessionId, this.movedObject.fiducialId, this.movedObject.objectRotation);
			}else{
				var rotationVal:Number = this.movedObject.objectRotation + (0.01 * (stage.mouseY-this.lastY));
				moveObject((this.movedObject as DisplayObjectContainer).x,(this.movedObject as DisplayObjectContainer).y, this.movedObject.sessionId, this.movedObject.fiducialId, rotationVal);
			}
			this.lastX = stage.mouseX;
			this.lastY = stage.mouseY;
		}
		
		/**
		 * takes care of the fiducial movement by dispatching an appropriate FiducialEvent or using the TuioManager and
		 * the TuioFiducialDispatcher to adjust the display of the fiducial in TuioDebug.
		 *  
		 * @param stageX the x coordinate of the mouse pointer 
		 * @param stageY the y coordinate of the mouse pointer 
		 * @param sessionId the session id of the fiducial 
		 * 
		 */
		private function moveObject(stageX:Number, stageY:Number, sessionId:uint, fiducialId:uint, rotation:Number):void{
			var frameId:uint = this.frameId++;
			var tuioObject:TuioObject = createTuioObject(fiducialId, stageX, stageY, sessionId, rotation, frameId);
			
			if(this.useTuioManager){
				TuioManager.getInstance().updateTuioObject(tuioObject);
				TuioFiducialDispatcher.getInstance().updateTuioObject(tuioObject);
			}else{
				var stagePos:Point = new Point(stageX, stageY);
				var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
				var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
				
				target.dispatchEvent(new FiducialEvent(FiducialEvent.MOVE, local.x, local.y, stagePos.x, stagePos.y, target, tuioObject));
			}
			
			if(this.useTuioDebug){
				TuioDebug.getInstance().updateTuioObjectWithDebugOption(tuioObject, true);
			}
		}
		
		/**
		 * Removes the move and up listener for fiducial movement.
		 *   
		 * @param event
		 * 
		 */
		private function dispatchObjectUp(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchObjectMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchObjectUp);
		}
		
		/**
		 * removes a fiducial from stage by dispatching an appropriate FiducialEvent or using the TuioManager and
		 * TuioFiducialDispatcher and removes the display of the fiducial in TuioDebug.
		 *  
		 * @param event
		 * 
		 */
		private function removeObject(event:MouseEvent):void{
			var frameId:uint = this.frameId++;
			var tuioObject:TuioObject = createTuioObject(this.movedObject.fiducialId, event.stageX, event.stageY, this.movedObject.sessionId, this.movedObject.objectRotation, frameId); 
			if(this.useTuioManager){
				TuioManager.getInstance().removeTuioObject(tuioObject);
				TuioFiducialDispatcher.getInstance().removeTuioObject(tuioObject);
			}else{
				var stagePos:Point = new Point(event.stageX, event.stageY);
				var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
				var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
				
				target.dispatchEvent(new FiducialEvent(FiducialEvent.REMOVED, local.x, local.y, stagePos.x, stagePos.y, target, tuioObject));
			}
			
			if(this.useTuioDebug){
				TuioDebug.getInstance().removeTuioObject(tuioObject);
			}	
		}
		
		private function createTuioObject(fiducialId:Number, stageX:Number, stageY:Number, sessionId:uint, rotation:Number, frameId:uint):TuioObject{
			return new TuioObject(TWO_D_OBJ,sessionId,fiducialId, stageX/stage.stageWidth, stageY/stage.stageHeight,0,rotation,0,0,0,0,0,0,0,0,0,0,frameId);
		}
		
		
		
		//==========================================  KEYBOARD STUFF ==========================================
		
		/**
		 * if the 'Space' key is being pressed spaceKey is set to true in this instance. 
		 * 
		 * If the 'r' key is being pressed rKey is set to true in this instance and the 
		 * barycentric coordinates of the touch group is being calculated. 
		 *  
		 * @param event
		 * 
		 */
		private function keyDown(event:KeyboardEvent):void{
			if(event.keyCode == 32){//space
				this.spaceKey = true;
			}
			if(event.keyCode == 82){//r
				if(!this.rKey){
					this.rKey = true;
				}
				
				var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(stage.mouseX, stage.mouseY);
				if(cursorUnderPoint != null && this.groups[cursorUnderPoint.sessionId] != null){
					//rotate around barycenter of touches
					var xPos:Number;
					var yPos:Number;
					var xPositions:Array = new Array();
					var yPositions:Array = new Array();
					var calcCenterPoint:Point = new Point();
					var touchAmount:Number = 0;
					
					calcCenterPoint.x = 0;
					calcCenterPoint.y = 0;
					
					
					for each(var cursorObject:Object in this.groups){
						var cursor:DisplayObjectContainer = cursorObject.cursor as DisplayObjectContainer;
						xPos = cursor.x;
						yPos = cursor.y;
						xPositions.push(xPos);
						yPositions.push(yPos);
						
						calcCenterPoint.x = calcCenterPoint.x + xPos;
						calcCenterPoint.y = calcCenterPoint.y + yPos;
						
						touchAmount = touchAmount+1;
					}
					this.rotationMouseX = calcCenterPoint.x/touchAmount;
					this.rotationMouseY = calcCenterPoint.y/touchAmount;
				}
			}
		}
		
		/**
		 * sets keyboard variables to false.
		 *  
		 * @param event
		 * 
		 */
		private function keyUp(event:KeyboardEvent):void{
			if(event.keyCode == 32){//space
				this.spaceKey = false;
			}
			if(event.keyCode == 82){//r
				this.rKey = false;
				this.rotationMouseX = 0;
				this.rotationMouseY = 0;
			}
		}
	}
}