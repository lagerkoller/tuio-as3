package org.tuio {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * The TochEvent is a multitouch version of Flash's MouseEvent.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioTouchEvent extends Event {
		
		/**Triggered on a touch.*/
		public static const TOUCH_DOWN:String = "org.tuio.TuioTouchEvent.TOUCH_DOWN";
		/**Triggered if a touch is released.*/
		public static const TOUCH_UP:String = "org.tuio.TuioTouchEvent.TOUCH_UP";
		/**Triggered if a touch is moved.*/
		public static const TOUCH_MOVE:String = "org.tuio.TuioTouchEvent.TOUCH_MOVE";
		/**Triggered if a touch is moved out of a DisplayObject.*/
		public static const TOUCH_OUT:String = "org.tuio.TuioTouchEvent.TOUCH_OUT";
		/**Triggered if a touch is moved over a DisplayObject.*/
		public static const TOUCH_OVER:String = "org.tuio.TuioTouchEvent.TOUCH_OVER";
		/**Triggered if a touch is moved out of a DisplayObject.*/
		public static const ROLL_OUT:String = "org.tuio.TuioTouchEvent.ROLL_OUT";
		/**Triggered if a touch is moved over a DisplayObject.*/
		public static const ROLL_OVER:String = "org.tuio.TuioTouchEvent.ROLL_OVER";
		
		/**Triggered if a TOUCH_DOWN and TOUCH_UP occurred over the same DisplayObject.*/
		public static const TAP:String = "org.tuio.TuioTouchEvent.TAP";
		/**Triggered if two subsequent TABs occurred over the same DisplayObject.*/
		public static const DOUBLE_TAP:String = "org.tuio.TuioTouchEvent.DOUBLE_TAP";
		
		/**Triggered if a touch is held for a certain time over the same DisplayObject without movement.*/
		public static const HOLD:String = "org.tuio.TuioTouchEvent.HOLD";
		
		private var _tuioContainer:TuioContainer;
		
		public var localX:Number = NaN;
		public var localY:Number = NaN;
		public var stageX:Number = NaN;
		public var stageY:Number = NaN;
		public var relatedObject:DisplayObject;
		
		public function TuioTouchEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = NaN, localY:Number = NaN, stageX:Number = NaN, stageY:Number = NaN, relatedObject:DisplayObject = null, tuioContainer:TuioContainer = null) {
			super(type, bubbles, cancelable);
			this._tuioContainer = tuioContainer;
			
			this.relatedObject = relatedObject;
			
			this.stageX = stageX;
			this.stageY = stageY;
				
			this.localX = localX;
			this.localY = localY;
		}
		
		public function get tuioContainer():TuioContainer {
			return this._tuioContainer;
		}
		
	}
	
}