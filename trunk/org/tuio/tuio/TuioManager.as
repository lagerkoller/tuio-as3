package org.tuio.tuio {
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import org.tuio.tuio.TouchEvent;
	
	/**
	 * The TuioManager class implements the ITuioListener interface and triggers events 
	 * into Flash's event flow according to the called callback functions.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioManager extends EventDispatcher implements ITuioListener {
		
		private var _tuioClient:TuioClient;
		private var lastTarget:Array;
		private var firstTarget:Array;
		
		public var stage:Stage;
		
		public function TuioManager(stage:Stage, tuioClient:TuioClient) {
			this._tuioClient = tuioClient;
			this._tuioClient.addListener(this);
			this.stage = stage;
			this.lastTarget = new Array();
			this.firstTarget = new Array();
		}
		
		private function handleAdd(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var targets:Array =  stage.getObjectsUnderPoint(stagePos);
			var target:DisplayObject = (targets.length > 0) ? targets[targets.length-1] : stage;
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			firstTarget[tuioContainer.sessionID] = target;
			lastTarget[tuioContainer.sessionID] = target;
			
			target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			target.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
		}
		
		private function handleUpdate(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var targets:Array =  stage.getObjectsUnderPoint(stagePos);
			var target:DisplayObject = (targets.length > 0) ? targets[targets.length-1] : stage;
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			var last:DisplayObject = lastTarget[tuioContainer.sessionID];
			
			//mouse move
			if (Math.abs(tuioContainer.X) > 0.001 || Math.abs(tuioContainer.Y) > 0.001 || Math.abs(tuioContainer.Z) > 0.001) {
				target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			//mouse out/over
			if (target != last) {
				var lastLocal:Point = last.globalToLocal(new Point(stagePos.x, stagePos.y));
				last.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_OUT, true, false, lastLocal.x, lastLocal.y, stagePos.x, stagePos.y, last, tuioContainer));
				last.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OUT, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				target.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			lastTarget[tuioContainer.sessionID] = target;
		}
		
		private function handleRemove(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var targets:Array =  stage.getObjectsUnderPoint(stagePos);
			var target:DisplayObject = (targets.length > 0) ? targets[targets.length-1] : stage;
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			
			//click
			if (target == firstTarget[tuioContainer.sessionID]) {
				target.dispatchEvent(new TouchEvent(TouchEvent.CLICK, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			lastTarget[tuioContainer.sessionID] = null;
			firstTarget[tuioContainer.sessionID] = null;
		}
		
		public function addTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioObject));
			this.handleAdd(tuioObject);
		}
		
		public function updateTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioObject));
			this.handleUpdate(tuioObject);
		}
		
		public function removeTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioObject));
			this.handleRemove(tuioObject);
		}

		public function addTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioCursor));
			this.handleAdd(tuioCursor);
		}
		
		public function updateTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioCursor));
			this.handleUpdate(tuioCursor);
		}
		
		public function removeTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioCursor));
			this.handleRemove(tuioCursor);
		}
		
		public function addTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioBlob));
			this.handleAdd(tuioBlob);
		}

		public function updateTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioBlob));
			this.handleUpdate(tuioBlob);
		}
		
		public function removeTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioBlob));
			this.handleRemove(tuioBlob);
		}
		
	}
	
}