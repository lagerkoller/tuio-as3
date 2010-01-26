package org.tuio.tuio {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import org.tuio.tuio.TouchEvent;
	import flash.utils.getTimer;
	
	/**
	 * The TuioManager class implements the ITuioListener interface and triggers events 
	 * into Flash's event flow according to the called callback functions.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioManager extends EventDispatcher implements ITuioListener {
		
		//number of milliseconds within two subsequent tabs trigger a double tab in ms
		public var doubleTabTimeout:int = 300;
		
		//the maximum distance between two subsequent tabs on the x/y axis to be counted as double tab in px
		public var doubleTabDistance:Number = 10;
		 
		//the time between a touch down event and a hold event in ms
		public var holdTimeout:int = 500;
		
		//if true a TouchEvent is triggered if a TuioObject is received
		public var triggerTouchOnObject:Boolean = false;
		
		//if true a TouchEvent is triggered if a TuioBlob is received
		public var triggerTouchOnBlob:Boolean = false;	
		
		//Sets the mode how to disvocer the TouchEvent's target object
		public var touchTargetDiscoveryMode:uint = TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
		
		//the possible touch target discovery modes.
		//no special handling -> top object under point -> fastest, works for all DisplayObjects
		public static const TOUCH_TARGET_DISCOVERY_NONE = 0;
		//uses the InteractiveObject's mouseEnabled parameter to determin whether a TouchEvent can be received by a candidate object.
		public static const TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED = 1;
		//uses an ignore list to determin whether a TouchEvent can be received by a candidate object.
		public static const TOUCH_TARGET_DISCOVERY_IGNORELIST = 2;
		
		private var _tuioClient:TuioClient;
		private var lastTarget:Array;
		private var firstTarget:Array;
		private var tabbed:Array;
		private var hold:Array;
		
		private var ignoreList:Array;
		
		public var stage:Stage;
		
		public function TuioManager(stage:Stage, tuioClient:TuioClient) {
			this._tuioClient = tuioClient;
			this._tuioClient.addListener(this);
			this.stage = stage;
			this.lastTarget = new Array();
			this.firstTarget = new Array();
			this.tabbed = new Array();
			this.hold = new Array();
			this.ignoreList = new Array();
		}
		
		private function handleAdd(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			firstTarget[tuioContainer.sessionID] = target;
			lastTarget[tuioContainer.sessionID] = target;
			hold[tuioContainer.sessionID] = getTimer();
			
			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			target.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
		}
		
		private function handleUpdate(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			var last:DisplayObject = lastTarget[tuioContainer.sessionID];
			
			//mouse move or hold
			if (Math.abs(tuioContainer.X) > 0.001 || Math.abs(tuioContainer.Y) > 0.001 || Math.abs(tuioContainer.Z) > 0.001) {
				hold[tuioContainer.sessionID] = getTimer();
				target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			} else if (hold[tuioContainer.sessionID] < getTimer() - holdTimeout) {
				hold[tuioContainer.sessionID] = getTimer();
				target.dispatchEvent(new TouchEvent(TouchEvent.HOLD, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			//mouse out/over
			if (target != last) {
				var lastLocal:Point = last.globalToLocal(new Point(stagePos.x, stagePos.y));
				last.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, true, false, lastLocal.x, lastLocal.y, stagePos.x, stagePos.y, last, tuioContainer));
				last.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OUT, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				target.dispatchEvent(new TouchEvent(TouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			lastTarget[tuioContainer.sessionID] = target;
		}
		
		private function handleRemove(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			
			//tab
			if (target == firstTarget[tuioContainer.sessionID]) {
				var double:Boolean = false;
				var tmpArray:Array = new Array();
				var item:DoubleTabStore;
				while (tabbed.length > 0) {
					item = tabbed.pop() as DoubleTabStore;
					if (item.check(this.doubleTabTimeout)) {
						if (item.target == target && Math.abs(stagePos.x-item.x) < this.doubleTabDistance && Math.abs(stagePos.y - item.y) < this.doubleTabDistance ) double = true;
						else tmpArray.push(item);
					}
				}
				tabbed = tmpArray.concat();
				
				if (double) {
					target.dispatchEvent(new TouchEvent(TouchEvent.DOUBLE_TAB, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				} else {
					tabbed.push(new DoubleTabStore(target, getTimer(), stagePos.x, stagePos.y));
					target.dispatchEvent(new TouchEvent(TouchEvent.TAB, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				}
			}
			
			lastTarget[tuioContainer.sessionID] = null;
			firstTarget[tuioContainer.sessionID] = null;
			hold[tuioContainer.sessionID] = null;
		}
		
		private function getTopDisplayObjectUnderPoint(point:Point):DisplayObject {
			var targets:Array =  stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;
			
			if(this.touchTargetDiscoveryMode == TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED){
				while(targets.length > 0) {
					item = targets.pop() as DisplayObject;
					if (item.parent != null && !(item is InteractiveObject)) item = item.parent;
					if (item is InteractiveObject) {
						if ((item as InteractiveObject).mouseEnabled) return item;
					}
				}
				item = stage;
			} else if (this.touchTargetDiscoveryMode == TOUCH_TARGET_DISCOVERY_IGNORELIST) {
				while(targets.length > 0) {
					item = targets.pop();
					if (ignoreList.indexOf(item) < 0) return item;
				}
				item = stage;
			}
			
			return item;
		}
		
		/**
		 * Adds the given DisplayObject to an internal list of DisplayObjects that won't receive TouchEvents.
		 * If a DisplayobjectContainer is added to the list its children can still receive TouchEvents.
		 * The touchTargetDiscoveryMode is automatically set to TOUCH_TARGET_DISCOVERY_IGNORELIST.
		 * 
		 * @param	item The DisplayObject that should be ignored by TouchEvents.
		 */
		public function addToIgnoreList(item:DisplayObject):void {
			this.touchTargetDiscoveryMode = TOUCH_TARGET_DISCOVERY_IGNORELIST;
			if(ignoreList.indexOf(item) < 0) ignoreList.push(item);
		}
		
		/**
		 * Removes the given DisplayObject from the internal list of DisplayObjects that won't receive TouchEvents.
		 * 
		 * @param	item The DisplayObject that should be ignored by TouchEvents.
		 */
		public function removeFromIgnoreList(item:DisplayObject):void {
			var ignoreListCopy:Array = ignoreList.concat();
			var tmpList:Array = new Array();
			var listItem:Object;
			while (ignoreListCopy.length > 0) {
				listItem = ignoreList.pop();
				if (listItem != item) tmpList.push(listItem);
			}
			ignoreList = tmpList.concat();
		}
		
		public function addTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioObject));
			if(triggerTouchOnObject) this.handleAdd(tuioObject);
		}
		
		public function updateTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioObject));
			if(triggerTouchOnObject) this.handleUpdate(tuioObject);
		}
		
		public function removeTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioObject));
			if(triggerTouchOnObject) this.handleRemove(tuioObject);
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
			if(triggerTouchOnBlob) this.handleAdd(tuioBlob);
		}

		public function updateTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioBlob));
			if(triggerTouchOnBlob) this.handleUpdate(tuioBlob);
		}
		
		public function removeTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioBlob));
			if(triggerTouchOnBlob) this.handleRemove(tuioBlob);
		}
		
	}
	
}

import flash.display.DisplayObject;
import flash.utils.getTimer;

internal class DoubleTabStore {
	
	internal var target:DisplayObject;
	internal var time:int;
	internal var x;
	internal var y;
	
	function DoubleTabStore(target:DisplayObject, time:int, x, y) {
		this.target = target;
		this.time = time;
		this.x = x;
		this.y = y;
	}
	
	function check(timeout:int):Boolean {
		if (time > getTimer() - timeout) return true;
		else return false;
	}
	
}