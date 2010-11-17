package org.tuio.gestures {
	
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
				//if there is a touch move go to the next step
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", frameIDAlias:"!A", targetAlias:"A" } ));
				//if there is another touch move in the same tuio frame with another session id go to the next step
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B", frameIDAlias:"A", targetAlias:"A" } ));
				//if either of the two earlier touches ends die else skip if next non dying step is saturated
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
				//if there is any other touch move by another touch die else skip if next non dying step is saturated
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
				//if there is a new touch move by the same finger registered earlier go to the next step
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", frameIDAlias:"!A", targetAlias:"A" } ));
				//if either of the two earlier touches ends die else skip if next non dying step is saturated
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
				//if there is any other touch move by another touch die else skip if next non dying step is saturated
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
				//if there is a new touch move by the same finger registered earlier in the same frame as the earlier move go to the next step
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B", frameIDAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
				//if there is a new tuio frame go to step 3 
			this.addStep(new GestureStep(TuioEvent.NEW_FRAME, {goto:3} ));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("two finger move" + getTimer());
		}
		
	}
	
}