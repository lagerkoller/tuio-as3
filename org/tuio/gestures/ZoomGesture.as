package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	public class ZoomGesture extends TwoFingerMoveGesture {
		
		private var lastDistance:Number;

		public function ZoomGesture() {
			super();
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			var diffX:Number = gsg.getTuioContainer("A").X * gsg.getTuioContainer("B").X;
			var diffY:Number = gsg.getTuioContainer("A").Y * gsg.getTuioContainer("B").Y;
			if (diffX <= 0 || diffY <= 0) {                           
				var distance:Number = Math.sqrt(Math.pow(gsg.getTuioContainer("A").x - gsg.getTuioContainer("B").x, 2) + Math.pow(gsg.getTuioContainer("A").y - gsg.getTuioContainer("B").y, 2));
				var scale:Number = 1;
				lastDistance = Number(gsg.getValue("lD"));
				
				if (lastDistance != 0) {
					scale = distance / lastDistance;
				}
				
				var center:Point = new Point((gsg.getTuioContainer("B").x + gsg.getTuioContainer("A").x)/2, (gsg.getTuioContainer("B").y + gsg.getTuioContainer("A").y)/2);
				var localPos:Point = gsg.getTarget("A").globalToLocal(new Point(center.x * gsg.getTarget("A").stage.stageWidth, center.y * gsg.getTarget("A").stage.stageHeight));
				gsg.getTarget("A").dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_ZOOM, true, false, null, localPos.x, localPos.y, scale, scale));
				gsg.storeValue("lD", distance);
			}
		}
		
	}
	
}