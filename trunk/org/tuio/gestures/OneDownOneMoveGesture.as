package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioTouchEvent;
	
	public class OneDownOneMoveGesture extends Gesture {
		
		public function OneDownOneMoveGesture() {
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, {tuioContainerAlias:"B"} ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, {tuioContainerAlias:"B", die:true}));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, {tuioContainerAlias:"B", goto:4}));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("one down one move " + getTimer());
		}
		
	}
	
}