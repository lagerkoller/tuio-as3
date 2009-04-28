package flash.events {
	
	import flash.display.DisplayObject;
	import flash.events.Event;	
	
	public class TouchEventMod extends Event
	{
		public var TUIO_TYPE:String;
		public var sID:int;
		public var ID:int;
		public var angle:Number;
		public var stageX:Number;
		public var stageY:Number;
		public var localX:Number;
		public var localY:Number;
		public var oldX:Number;
		public var oldY:Number;
		public var buttonDown:Boolean;
		public var relatedObject:DisplayObject;
		
		public static const MOUSE_DOWN:String = "flash.events.TouchEventMod.MOUSE_DOWN";		
		public static const MOUSE_MOVE:String = "flash.events.TouchEventMod.MOUSE_MOVE";
		public static const MOUSE_UP:String = "flash.events.TouchEventMod.MOUSE_UP";
		public static const MOUSE_OVER:String = "flash.events.TouchEventMod.MOUSE_OVER";
		public static const MOUSE_OUT:String = "flash.events.TouchEventMod.MOUSE_OUT";
		//
		public static const CLICK:String = "flash.events.TouchEventMod.CLICK";
	
		public static const DOUBLE_CLICK:String = "flash.events.TouchEventMod.DOUBLE_CLICK";
	
		// SHOULD THESE BE MOVED TO MULTITOUCHABLE???------------------------------------------------
		// TODO: RENAME LONG_PRESS to HOLD
		// Dynamic HOLD times [addEventListner(TouchEvent.HOLD, function, setHoldTime)]
		public static const LONG_PRESS:String = "flash.events.TouchEventMod.LONG_PRESS";	
			/*
		// TODO: SEE David's Physical.fla test (continuous vs discrete pinching)
		public static const PINCH_IN:String = "flash.events.TouchEvent.PINCH_IN";		
		public static const PINCH_OUT:String = "flash.events.TouchEvent.PINCH_OUT";	
		public static const SWIPE_LEFT:String = "flash.events.TouchEvent.SWIPE_LEFT";
		public static const SWIPE_RIGHT:String = "flash.events.TouchEvent.SWIPE_RIGHT";
		public static const SWIPE_UP:String = "flash.events.TouchEvent.SWIPE_UP";
		public static const SWIPE_DOWN:String = "flash.events.TouchEvent.SWIPE_DOWN";
		
		// TAP COUNTING
		
		*/
//---------------------------------------------------------------------------------------------------------------------------------------------	
// CONSTRUCTOR
//---------------------------------------------------------------------------------------------------------------------------------------------
		public function TouchEventMod(type:String, bubbles:Boolean = false, cancelable:Boolean = false, stageX:Number = 0, stageY:Number = 0, localX:Number = 0, localY:Number = 0, oldX:Number = 0, oldY:Number = 0, relatedObject:DisplayObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0, TUIO_TYPE:String = "2Dcur", ID:int = -1, sID:int = -1, angle:Number = 0.0)
		{
			this.TUIO_TYPE = TUIO_TYPE;
			this.sID = sID;
			this.ID = ID;
			this.angle = angle;
			this.stageX = stageX;
			this.stageY = stageY;
			this.localX = localX;
			this.localY = localY;			
			this.oldX = oldX;
			this.oldY = oldY;
			this.buttonDown = buttonDown;
			this.relatedObject = relatedObject;			
			super(type, bubbles, cancelable);			
			//super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);	
		}
//---------------------------------------------------------------------------------------------------------------------------------------------
	}
}