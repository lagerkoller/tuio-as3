package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	
	public class Gesture {
			
		public static const SATURATED:uint = 1;
		public static const ALIVE:uint = 2;
		public static const PROGRESS:uint = 3;
		public static const DEAD:uint = 4;
		
		private var _steps:GestureStepGroup;
		private var init:Boolean;
		
		public function Gesture() {
			this._steps = new GestureStepGroup();
			this._steps.gesture = this;
		}
		
		protected function addStep(s:GestureStep):void {
			this._steps.addStep(s);
		}
		
		public function get firstStep():GestureStep {
			return this._steps.firstStep;
		}
		
		public function get steps():GestureStepGroup {
			return this._steps.copy();
		}
		
		public function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepGroup):void {
			trace("dispatching");
		}
		
	}
	
}