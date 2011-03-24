package org.tuio.adapters
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.tuio.TuioClient;
	import org.tuio.TuioContainer;
	import org.tuio.TuioCursor;
	import org.tuio.TuioManager;
	import org.tuio.debug.TuioDebug;
	import org.tuio.util.DisplayListHelper;

	/**
	 * Listens on <em>native</em> TouchEvents (currently only supported on touch enabled hardware running with
	 * Windows 7) and translates them into <code>TuioTouchEvent</code>s. Hence, applications created with TUIO
	 * AS 3 that use this adapter can be used with native (currently Windows 7 only) touch hardware.  
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class NativeTuioAdapter extends AbstractTuioAdapter{
		
		private var stage:Stage;
		private var useTuioManager:Boolean;
		private var useTuioDebug:Boolean;
		private var lastPos:Array;
		private var frameId:uint = 0;
		
		public function NativeTuioAdapter(stage:Stage){
			super(this);
			this.stage = stage;
			
			this.lastPos = new Array();
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, dispatchTouchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, dispatchTouchUp);
			
			stage.addEventListener(TouchEvent.TOUCH_TAP, dispatchTap);
		}
		
		private function dispatchTap(event:TouchEvent):void{
			var stagePos:Point = new Point(event.stageX, event.stageY);
			var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new org.tuio.TuioTouchEvent(org.tuio.TuioTouchEvent.TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, createTuioContainer(event)));
		}
		
		private function touchBegin(event:TouchEvent):void{
			this.frameId = this.frameId + 1;
			var tuioCursor:TuioCursor = createTuioCursor(event);
			tuioCursors.push(tuioCursor);
			dispatchAddCursor(tuioCursor);
			lastPos[event.touchPointID] = new Point(event.stageX, event.stageY);
		}
		
		private function dispatchTouchMove(event:TouchEvent):void{
			this.frameId = this.frameId + 1;
			var tuioCursor:TuioCursor = getTuioCursor(event.touchPointID); 
			updateTuioCursor(tuioCursor, event);
			dispatchUpdateCursor(tuioCursor);
			lastPos[event.touchPointID] = new Point(event.stageX, event.stageY);
		}
		
		private function dispatchTouchUp(event:TouchEvent):void{
			this.frameId = this.frameId + 1;
			dispatchRemoveCursor(getTuioCursor(event.touchPointID));
			lastPos[event.touchPointID] = null;
			delete lastPos[event.touchPointID];
		}
		
		private function createTuioContainer(event:TouchEvent):TuioContainer{
			var diffX:Number = 0, diffY:Number = 0;
			if (lastPos[event.touchPointID]) {
				diffX = (event.stageX - lastPos[event.touchPointID].x)/stage.stageWidth;
				diffY = (event.stageY - lastPos[event.touchPointID].y)/stage.stageHeight;
			}
			return new TuioContainer("2Dcur",event.touchPointID,event.stageX/stage.stageWidth, event.stageY/stage.stageHeight,0,diffX,diffY,0,0,0,'NativeTuioAdapter');
		}
		private function createTuioCursor(event:TouchEvent):TuioCursor{
			var diffX:Number = 0, diffY:Number = 0;
			if (lastPos[event.touchPointID]) {
				diffX = (event.stageX - lastPos[event.touchPointID].x)/stage.stageWidth;
				diffY = (event.stageY - lastPos[event.touchPointID].y)/stage.stageHeight;
			}
			return new TuioCursor("2Dcur",event.touchPointID,event.stageX/stage.stageWidth, event.stageY/stage.stageHeight,0,diffX,diffY,0,0,0,'NativeTuioAdapter');
		}
		private function updateTuioCursor(tuioCursor:TuioCursor, event:TouchEvent):void{
			var diffX:Number = 0, diffY:Number = 0;
			if (lastPos[event.touchPointID]) {
				diffX = (event.stageX - lastPos[event.touchPointID].x)/stage.stageWidth;
				diffY = (event.stageY - lastPos[event.touchPointID].y)/stage.stageHeight;
			}
			tuioCursor.update(event.stageX/stage.stageWidth, event.stageY/stage.stageHeight,0,diffX/stage.stageWidth,diffY/stage.stageHeight,0,0,this.frameId);
		}
		
	}
}