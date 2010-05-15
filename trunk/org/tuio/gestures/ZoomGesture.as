package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioEvent;
	import org.tuio.TouchEvent;
	
	public class ZoomGesture extends TwoFingerMoveGesture {
		
		private var lastDistance:Number;
		
		public function ZoomGesture() {
			this.addEventListener(GestureStepEvent.DEAD, handleDead);
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepGroup):void {
			var diffX:Number = gsg.getTuioContainer("A").X * gsg.getTuioContainer("B").X;
			var diffY:Number = gsg.getTuioContainer("A").Y * gsg.getTuioContainer("B").Y;
			if (diffX < 0 || diffY < 0) {
				trace("zoom " + getTimer() + gsg.getTarget("A").name);
				
				var distance:Number = Math.sqrt(Math.pow(gsg.getTuioContainer("A").x - gsg.getTuioContainer("B").x, 2) + Math.pow(gsg.getTuioContainer("A").y - gsg.getTuioContainer("B").y, 2));
				
				if (lastDistance) {
					gsg.getTarget("A").scaleX = gsg.getTarget("A").scaleY = gsg.getTarget("A").scaleX - gsg.getTarget("A").scaleX * (lastDistance - distance);
				}
				lastDistance = distance;
			}
		}
		
		private function handleDead(e:GestureStepEvent):void {
			if (e.step <= 5 && e.step != 3) {
				trace("dead");
				lastDistance = NaN;
			}
		}
		
	}
	
}