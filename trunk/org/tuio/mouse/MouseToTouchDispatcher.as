package org.tuio.mouse
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.tuio.TouchEvent;
	import org.tuio.TuioContainer;
	import org.tuio.TuioCursor;
	import org.tuio.TuioManager;
	import org.tuio.debug.ITuioDebugBlob;
	import org.tuio.debug.ITuioDebugCursor;
	import org.tuio.debug.ITuioDebugObject;
	import org.tuio.debug.ITuioDebugTextSprite;
	import org.tuio.debug.TuioDebug;

	/**
	 * Listens on MouseEvents, "translates" them to the analog TouchEvents and dispatches
	 * them on <code>DisplayObject</code>s under the mouse pointer.
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
		
		public function MouseToTouchDispatcher(stage:Stage, useTuioManager:Boolean = true, useTuioDebug:Boolean = true)
		{
			this.stage = stage; 
			stage.addEventListener(MouseEvent.CLICK, dispatchTap);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, dispatchDoubleTap);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, dispatchTouchDown);
			
			this.useTuioManager = useTuioManager; 
			this.useTuioDebug = useTuioDebug;
		}
		
		private function dispatchTap(event:MouseEvent):void{
			var stagePos:Point = new Point(event.stageX, event.stageY);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new TouchEvent(TouchEvent.TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
		}
		private function dispatchDoubleTap(event:MouseEvent):void{
			var stagePos:Point = new Point(event.stageX, event.stageY);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new TouchEvent(TouchEvent.DOUBLE_TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
		}
		private function dispatchTouchDown(event:MouseEvent):void{
//			var stagePos:Point = new Point(event.stageX, event.stageY);
//			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
//			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
//			
//			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
			if(this.useTuioManager){
				TuioManager.getInstance().handleAdd(createTuioContainer(event));
			}
			if(this.useTuioDebug){
				TuioDebug.getInstance().addTuioCursor(createTuioCursor(event));
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
		}
		private function dispatchTouchMove(event:MouseEvent):void{
//			var stagePos:Point = new Point(event.stageX, event.stageY);
//			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
//			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
//			
//			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
			if(this.useTuioManager){
				TuioManager.getInstance().handleUpdate(createTuioContainer(event));
			}
			if(this.useTuioDebug){
				TuioDebug.getInstance().updateTuioCursor(createTuioCursor(event));
			}
		}
		private function dispatchTouchUp(event:MouseEvent):void{
//			var stagePos:Point = new Point(event.stageX, event.stageY);
//			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
//			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
//			
//			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
			if(this.useTuioManager){
				TuioManager.getInstance().handleRemove(createTuioContainer(event));
			}
			if(this.useTuioDebug){
				TuioDebug.getInstance().removeTuioCursor(createTuioCursor(event));
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
		}
		private function createTuioContainer(event:MouseEvent):TuioContainer{
			return new TuioContainer("2Dcur",-5,event.stageX/stage.stageWidth, event.stageY/stage.stageHeight,0,0,0,0,0);
		}
		private function createTuioCursor(event:MouseEvent):TuioCursor{
			return new TuioCursor("2Dcur",-5,event.stageX/stage.stageWidth, event.stageY/stage.stageHeight,0,0,0,0,0);
		}
		private function getTopDisplayObjectUnderPoint(point:Point):DisplayObject {
			var targets:Array =  stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;
			
			while(targets.length > 0) {
				item = targets.pop() as DisplayObject;
				//ignore debug cursor/object/blob and send object under debug cursor/object/blob
				if((item is ITuioDebugCursor || item is ITuioDebugBlob || item is ITuioDebugObject || item is ITuioDebugTextSprite) && targets.length > 1){
					continue;
				}
				if (item.parent != null && !(item is InteractiveObject)) item = item.parent;
				if (item is InteractiveObject) {
					if ((item as InteractiveObject).mouseEnabled) return item;
				}
			}
			item = stage;
			
			return item;
		}
		
		private function bubbleListCheck(obj:DisplayObject):Boolean {
			if (obj.parent != null) {
				return bubbleListCheck(obj.parent);
			} else {
				return false;
			}
		}
	}
}