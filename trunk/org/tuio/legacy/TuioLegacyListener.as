/**
 * TuioLegacyListener takes over the interface duties of the old TUIO class. As TuioLegacyListener is
 * implemented as a Singleton class, there can only be one instance of TuioLegacyListener in the Flash
 * app. This provides global access to the functions of TuioLegacyListener. 
 * 
 * TuioLegacyListener implements the interface ITuioListener. Thus, it is being called whenever a Tuio
 * object, cursor or blob is being received. When a cursor (== a touch) is being received in the function 
 * addTuioCursor, addTuioCursor looks if there is a DisplayObject under the cursor and dispatches a 
 * TouchEvent.MOUSE_DOWN on this DisplayObject. Additionally, a TouchEvent.MOUSE_DOWN is being dispatched 
 * on the stage.
 * 
 * Following legacy functions have been transfered from TUIO to TuioLegacyListener:
 * - listenForObject
 * - getObjectById 
 * 
 */
package org.tuio.legacy
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	
	import org.tuio.tuio.ITuioListener;
	import org.tuio.tuio.TuioBlob;
	import org.tuio.tuio.TuioClient;
	import org.tuio.tuio.TuioCursor;
	import org.tuio.tuio.TuioObject;

	public class TuioLegacyListener implements ITuioListener
	{
		private var stage:Stage;
		private var tuioClient:TuioClient;
		private var listenOnIdsArray:Array;
		
		private static var allowInst:Boolean;
		private static var inst:TuioLegacyListener; 
		
		
		public function TuioLegacyListener(stage:Stage, tuioClient:TuioClient){
			if (!allowInst) {
	            throw new Error("Error: Instantiation failed: Use TuioLegacyListener.getInstance() instead of new.");
			}else{
				this.stage = stage;
				this.tuioClient = tuioClient;
				this.tuioClient.addListener(this);
				this.listenOnIdsArray = new Array();
			}
			
		}
		
		/**
		 * initializes Singleton instance.
		 */
		public static function init(stage:Stage, tuioClient:TuioClient):TuioLegacyListener{
			if(inst == null){
				allowInst = true;
				inst = new TuioLegacyListener(stage, tuioClient);
				allowInst = false;
			}
			
			return inst;
		}
		
		/**
		 * gets Singleton instance
		 */
		public static function getInstance():TuioLegacyListener{
			if(inst == null){
				throw new Error("Please initialize with method init(...) first!");
			}
			return inst;
		} 

		public function addTuioObject(tuioObject:TuioObject):void{
			
		}
		
		public function updateTuioObject(tuioObject:TuioObject):void{
		}
		
		public function removeTuioObject(tuioObject:TuioObject):void{
		}
		
		/**
		 * dispatches TouchEvent.MOUSE_DOWN and TouchEvent.MOUSE_OVER events on the DisplayObject under the touch. 
		 * Additionally, the same events are being dispatched on the stage object in order to provide the possibility 
		 * to objects to listen on TouchEvents that are being dispatched on the stage (useful for the implementation of 
		 * dragging and so on). 
		 */
		public function addTuioCursor(tuioCursor:TuioCursor):void{
			var dobj:DisplayObject;
			var stagePoint:Point;					
			var displayObjArray:Array;
			
			stagePoint = new Point((int)(stage.stageWidth*tuioCursor.x), (int)(stage.stageHeight*tuioCursor.y));					
			displayObjArray = this.stage.getObjectsUnderPoint(stagePoint);
			dobj = null;
			
			if(displayObjArray.length > 0){							
				dobj = displayObjArray[displayObjArray.length - 1];
				var localPoint:Point = dobj.parent.globalToLocal(new Point(stagePoint.x, stagePoint.y));				
				dobj.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_DOWN, true, false, stagePoint.x, stagePoint.y, localPoint.x, localPoint.y, 0, 0, dobj, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));									
				dobj.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_OVER, true, false, stagePoint.x, stagePoint.y, localPoint.x, localPoint.y, 0, 0, dobj, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));
			}
			stage.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_DOWN, true, false, stagePoint.x, stagePoint.y, stagePoint.x, stagePoint.y, 0, 0, null, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));									
			stage.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_OVER, true, false, stagePoint.x, stagePoint.y, stagePoint.x, stagePoint.y, 0, 0, null, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));
		}
		
		/**
		 * dispatches TouchEvent.MOUSE_MOVE events on the stage whenever a touch is being updated.
		 * 
		 * Additionally, TouchEvent.MOUSE_MOVE events are being dispatched on all receiver objects in
		 * the Array listenOnIdsArray, which listen on the id of the updated touch.
		 */
		public function updateTuioCursor(tuioCursor:TuioCursor):void{
			var stagePoint:Point = new Point((int)(stage.stageWidth*tuioCursor.x), (int)(stage.stageHeight*tuioCursor.y));
			stage.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_MOVE, true, false, stagePoint.x, stagePoint.y, stagePoint.x, stagePoint.y, 0, 0, null, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));
			
			//legacy listener concept: dispatch MOUSE_MOVE event on objects in listener array
			var localPoint:Point;
			for each(var listeningObject:Object in listenOnIdsArray){
				if(listeningObject.id == tuioCursor.sessionID){
					localPoint = listeningObject.receiver.parent.globalToLocal(new Point(stagePoint.x, stagePoint.y));			
					listeningObject.receiver.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_MOVE, true, false, stagePoint.x, stagePoint.y, localPoint.x, localPoint.y, 0, 0, listeningObject.receiver, false,false,false, true, 0, "2Dcur", tuioCursor.sessionID, -1, 0));
				}	
			}
		}
		
		/**
		 * dispatches TouchEvent.MOUSE_UP events on the stage whenever a touch is being removed.
		 * 
		 * Additionally, TouchEvent.MOUSE_UP events are being dispatched on all receiver objects in
		 * the Array listenOnIdsArray, which listen on the id of the removed touch.
		 */
		public function removeTuioCursor(tuioCursor:TuioCursor):void{
			var stagePoint:Point = new Point((int)(stage.stageWidth*tuioCursor.x), (int)(stage.stageHeight*tuioCursor.y));
			stage.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_UP, true, false, stagePoint.x, stagePoint.y, stagePoint.x, stagePoint.y, 0, 0, null, false,false,false, true, 0,"2Dcur", tuioCursor.sessionID, tuioCursor.sessionID, 0));
			
			//legacy listener concept: dispatch MOUSE_UP event on objects in listener array
			var localPoint:Point;
			for each(var listeningObject:Object in listenOnIdsArray){
				if(listeningObject.id == tuioCursor.sessionID){
					localPoint = listeningObject.receiver.parent.globalToLocal(new Point(stagePoint.x, stagePoint.y));			
					listeningObject.receiver.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_UP, true, false, stagePoint.x, stagePoint.y, localPoint.x, localPoint.y, 0, 0, listeningObject.receiver, false,false,false, true, 0, "2Dcur", tuioCursor.sessionID, -1, 0));
					removeListenForObject(listeningObject.id, listeningObject.receiver);
				}	
			}
		}
		
		public function addTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		
		public function updateTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		
		public function removeTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		
		/**
		 * allows a receiver DisplayObject to register themself to be notified whenever
		 * a touch with the id id arrives.
		 */
		public function listenForObject(id:Number, receiver:Object):void{
			var tmpObj:TUIOObject = getObjectById(id);			
			if(tmpObj != null){
				var listeningObject:Object = {id:id, receiver:receiver};
				listenOnIdsArray.push(listeningObject);
			}
		}
		
		/**
		 * removes a receiver DisplayObject to listen on touches with the id id.
		 */
		public function removeListenForObject(id:Number, receiver:Object):void {
			var i:Number = 0;
			for each(var listeningObject:Object in listenOnIdsArray){
				if(listeningObject.id == id && listeningObject.receiver == receiver){
					listenOnIdsArray.splice(i,1);					
				}
				i = i+1;
			}
		}
		
		/**
		 * takes over the duties of the function getObjectById from TUIO. getObjectById looks in 
		 * the global cursor list (tuioClient.getTuioCursors()) for the tuio element with the id id.
		 * It this element is being found it will be repackaged into a (legacy) TUIOObject instance and
		 * returned to the caller.
		 */		
		public function getObjectById(id:Number):TUIOObject {
			var tuioObject:TUIOObject;
			//returns mouse cursor as blob
			if(id == 0){
				tuioObject = new TUIOObject("mouse", 0, stage.mouseX, stage.mouseY, 0, 0, 0, 0, 10, 10, null);
			}else{
				//look for blob/cursor in list
				var objectArray:Array = tuioClient.tuioCursors;
				for(var i:int=0; i<objectArray.length; i++)  {
					if(objectArray[i].sessionID == id){
						var stagePoint:Point = new Point((int)(stage.stageWidth*objectArray[i].x), (int)(stage.stageHeight*objectArray[i].y));
						var diffPoint:Point = new Point((int)(stage.stageWidth*objectArray[i].X), (int)(stage.stageHeight*objectArray[i].Y));
						tuioObject = new TUIOObject("2Dcur", id, stagePoint.x, stagePoint.y, diffPoint.x, diffPoint.y,-1,0,0,0, null);
						break;
					}
				}
			}
			return tuioObject;
		}
		
	}
}