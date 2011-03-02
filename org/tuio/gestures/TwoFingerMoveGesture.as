package org.tuio.gestures {
	
	import examples.gestures.GestureManagerExample;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * This is an example implementation of a TwoFingerMoveGesture.
	 * It is recommended to modify this event to fit the wanted behaviour.
	 */
	public class TwoFingerMoveGesture extends Gesture {
		
		public function TwoFingerMoveGesture() {
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", frameIDAlias:"!A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B", frameIDAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", frameIDAlias:"A", targetAlias:"A"} ));
			this.addStep(new GestureStep(TuioEvent.NEW_FRAME, {} ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { optional:true, tuioContainerAlias:"B", goto:4 } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A"} ));
			this.addStep(new GestureStep(TuioEvent.NEW_FRAME, { optional:true, goto:5 } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));	
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioEvent.NEW_FRAME, { goto:5 } ));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("two finger move" + getTimer());
		}
		
	}
	
}