package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioEvent;
	import org.tuio.TouchEvent;
	
	public class ScrollGesture extends TwoFingerMoveGesture {
		
		public function ScrollGesture() {}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepGroup):void {
			var diffX:Number = gsg.getTuioContainer("A").X - gsg.getTuioContainer("B").X;
			var diffY:Number = gsg.getTuioContainer("A").Y - gsg.getTuioContainer("B").Y;
			if (diffX < 0.01 || diffY < 0.01) {
				trace("scroll " + getTimer());
			}
		}
		
	}
	
}