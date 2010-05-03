package org.tuio {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import org.tuio.gestures.*;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	
	/**
	 * The GestureManager listens to the TuioManager and triggers
	 * gesture events into Flash's event flow according to the called callback functions
	 * and registered Gestures.
	 * 
	 * @author Immanuel Bauer
	 */
	public class GestureManager extends EventDispatcher {
				
		/**Sets the method how to discover the TouchEvent's target object. The default is TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED.*/
		public var touchTargetDiscoveryMode:uint = TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
		
		//the possible touch target discovery modes.
		/**The events will be triggered on the top object under the tracked point. Fastest method. Works for DisplayObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_NONE:Number = 0;
		/**The InteractiveObject's mouseEnabled parameter is used to determine whether a TouchEvent is triggered on an InteractiveObject under the tracked point. Works only for InteractiveObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED:Number = 1;
		/**An ignore list is used to determin whether a TouchEvent is triggered on an InteractiveObject under the tracked point. Works for DisplayObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_IGNORELIST:Number = 2;
		
		private var _tuioManager:TuioManager;
		
		private var ignoreList:Array;
		
		private var gestures:Array;
		private var activeGestures:Array;
		
		private static var inst:GestureManager;
		private static var allowInst:Boolean = false;
		
		internal var stage:Stage;
		
		/**
		 * Creates a new TuioManager instance which processes the Tuio tracking data received by the given TuioClient.
		 * 
		 * @param	stage The Stage object of the Flashmovie.
		 * @param	tuioClient A TuioClient instance that receives Tuio tracking data from a tracker.
		 */
		public function GestureManager() {
			if(allowInst){
				this._tuioManager = TuioManager.getInstance();
				this._tuioManager.addEventListener(TuioEvent.ADD, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.ADD_CURSOR, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.ADD_OBJECT, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.ADD_BLOB, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.UPDATE, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.UPDATE_CURSOR, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.UPDATE_OBJECT, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.UPDATE_BLOB, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.REMOVE, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.REMOVE_CURSOR, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.REMOVE_OBJECT, handleTuioEvent);
				this._tuioManager.addEventListener(TuioEvent.REMOVE_BLOB, handleTuioEvent);
				this._tuioManager.addEventListener(TouchEvent.TAP, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.DOUBLE_TAP, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.HOLD, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.ROLL_OVER, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.ROLL_OUT, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.TOUCH_DOWN, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.TOUCH_UP, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.TOUCH_OUT, handleTouchEvent);
				this._tuioManager.addEventListener(TouchEvent.TOUCH_OVER, handleTouchEvent);
				this.ignoreList = new Array();
				this.gestures = new Array();
				this.activeGestures = new Array();
				this.addGesture(new ScrollGesture());
				this.addGesture(new OneDownOneMoveGesture());
				this.addGesture(new PressTapGesture());
			} else {
				throw new Error("Error: Instantiation failed: Use GestureManager.getInstance() instead of new.");
			}
		}
		
		public static function init(stage:Stage, tuioClient:TuioClient):GestureManager {
			if(inst == null){
				TuioManager.init(stage, tuioClient);
				allowInst = true;
				inst = new GestureManager();
				inst.stage = stage;
				allowInst = false;
			}
			
			return inst;
		}
		
		public static function getInstance():GestureManager{
			if(inst == null){
				throw new Error("Please initialize with method GestureManager.init(...) first!");
			}
			return inst;
		}
		
		public function addGesture(gesture:Gesture):void {
			this.gestures.push(gesture);
		}
		
		private function initGestures(event:String, target:DisplayObject, tuioContainer:TuioContainer):void {
			var gsg:GestureStepGroup;
			for each(var g:Gesture in gestures) {
				if (g.firstStep.event == event) {
					gsg = g.steps;
					gsg.step(event, target, tuioContainer);
					this.activeGestures.push(gsg);
				}
			}
		}
		
		private function progressGestures(event:String, target:DisplayObject, tuioContainer:TuioContainer):Boolean {
			var temp:Array = new Array();
			var l:int = this.activeGestures.length;
			var used:Boolean = false;
			
			for (var c:int = 0; c < l; c++ ) {
				var m:GestureStepGroup = this.activeGestures.pop();
				var r:uint = m.step(event, target, tuioContainer);
				if (r == Gesture.PROGRESS) {
					temp.push(m);
					used = true;
				} else if (r == Gesture.ALIVE) {
					temp.push(m);
				} else if (r == Gesture.SATURATED) {
					used = true;
					m.gesture.dispatchGestureEvent(target, m);
					if (m.active) temp.push(m);
				}
			}
			this.activeGestures = temp;
			return used;
		}
		
		private function handleTouchEvent(touchEvent:TouchEvent):void {
			if (!progressGestures(touchEvent.type, touchEvent.target as DisplayObject, touchEvent.tuioContainer)) {
				initGestures(touchEvent.type, touchEvent.target as DisplayObject, touchEvent.tuioContainer);
			}
		}
		
		private function handleTuioEvent(tuioEvent:TuioEvent):void {
			var tuioContainer:TuioContainer = tuioEvent.tuioContainer;
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			
			if (!progressGestures(tuioEvent.type, target, tuioEvent.tuioContainer)) {
				initGestures(tuioEvent.type, target, tuioEvent.tuioContainer);
			}
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
				while (targets.length > 0) {
					item = targets.pop();
					if (!bubbleListCheck(item)) return item;
				}
				item = stage;
			}
			
			return item;
		}
		
		/**
		 * Checks if a DisplayObject or its parents are in the ignoreList.
		 * 
		 * @param	obj The DisplayObject that has to be checked.
		 * @return Is true if the DisplayObject or one of its parents is in the ignoreList.
		 */
		private function bubbleListCheck(obj:DisplayObject):Boolean {
			if (ignoreList.indexOf(obj) < 0){
				if (obj.parent != null) {
					return bubbleListCheck(obj.parent);
				} else {
					return false;
				}
			} else {
				return true;
			}
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
			var tmpList:Array = new Array();
			var listItem:Object;
			while (ignoreList.length > 0) {
				listItem = ignoreList.pop();
				if (listItem != item) tmpList.push(listItem);
			}
			ignoreList = tmpList.concat();
		}
		
	}
	
}