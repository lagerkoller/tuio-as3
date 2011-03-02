package examples.gestures {
	import flash.display.Sprite;
	import flash.events.TransformGestureEvent;
	import org.tuio.TuioTouchEvent;
	import flash.geom.*;
	
	public class DragRotateScaleMe extends Sprite {
		
		public var minScale:Number = 0.1;
		public var maxScale:Number = 2.5;
		
		private var curID:int = -1;
		
		public function DragRotateScaleMe(x:Number, y:Number, width:Number, height:Number) {
			this.graphics.beginFill(Math.random() * 0xcccccc);
			this.graphics.drawRect( -width / 2, -height / 2, width, height);
			this.graphics.endFill();
			this.x = x + width / 2;
			this.y = y + height / 2;
			
			this.addEventListener(TransformGestureEvent.GESTURE_PAN, handleDrag);
			this.addEventListener(TransformGestureEvent.GESTURE_ZOOM, handleScale);
			this.addEventListener(TransformGestureEvent.GESTURE_ROTATE, handleRotate);
			this.addEventListener(TuioTouchEvent.TOUCH_DOWN, handleDown);
		}
		
		private function handleScale(e:TransformGestureEvent):void {
			var p:Point  = this.localToGlobal(new Point(e.localX, e.localY));
			p = parent.globalToLocal(p);
			
			var m:Matrix = this.transform.matrix;
			m.translate( -p.x, -p.y);
			m.scale(e.scaleX, e.scaleY);
			m.translate(p.x, p.y);
			this.transform.matrix = m;
			
			if (this.scaleX > maxScale) {
				m = this.transform.matrix;
				m.translate( -p.x, -p.y);
				m.scale(maxScale/this.scaleX, maxScale/this.scaleY);
				m.translate(p.x, p.y);
				this.transform.matrix = m;
			} else if (this.scaleX < minScale) {
				m = this.transform.matrix;
				m.translate( -p.x, -p.y);
				m.scale(minScale/this.scaleX, minScale/this.scaleY);
				m.translate(p.x, p.y);
				this.transform.matrix = m;
			}
		}
		
		private function handleRotate(e:TransformGestureEvent):void {
			var p:Point  = this.localToGlobal(new Point(e.localX, e.localY));
			p = parent.globalToLocal(p);
			
			var m:Matrix = this.transform.matrix;
			m.translate(-p.x, -p.y);
			m.rotate(e.rotation * (Math.PI / 180));
			m.translate(p.x, p.y);
			this.transform.matrix = m;
		}
		
		private function handleDrag(e:TransformGestureEvent):void {
			this.x += e.offsetX;
			this.y += e.offsetY;
		}
		
		private function handleDown(e:TuioTouchEvent):void {
			if (curID == -1) {
				stage.setChildIndex(this, stage.numChildren - 1);
				this.curID = e.tuioContainer.sessionID;
				stage.addEventListener(TuioTouchEvent.TOUCH_UP, handleUp);
			}
		}
		
		private function handleUp(e:TuioTouchEvent):void {
			if(e.tuioContainer.sessionID == this.curID){
				this.curID = -1;
				stage.removeEventListener(TuioTouchEvent.TOUCH_UP, handleUp);
			}
		}
		
	}
	
}