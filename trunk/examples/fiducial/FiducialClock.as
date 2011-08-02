package
{
	import ascb.drawing.Pen;
	
	import caurina.transitions.Tweener;
	
	import ext.transitions.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.Timer;
	
	/**
	 * An animation that lets a torus appear in a circular fashion which indicates a clock.
	 *  
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class FiducialClock extends Sprite
	{
		private var timer:Timer;
		private var rotationSprite:Sprite;
		private var clockAngle:Number;
		private var clockPen:Pen;
		private var remove:Boolean;
		private var callback:Function;
		private var active:Boolean;
		private var clockRadius:Number;
		private var stepCount:Number;
		
		
		public function FiducialClock(frameRate:Number, duration:Number = 300, clockRadius:Number = 100)
		{
			this.addEventListener(Event.ENTER_FRAME, updateClock);
			
			this.stepCount = duration/1000*frameRate;
			
			this.clockRadius = clockRadius;
			
			this.clockPen = new Pen(this.graphics);
			this.rotationSprite = new Sprite();
			this.clockAngle = 0;
			this.remove = false;
			
			
			var filt:DropShadowFilter = new DropShadowFilter();
			filt.angle = 90;
			filt.blurX = 10;
			filt.blurY = 10;
			filt.distance = 5;
			filt.color = 0x787878;
			filt.inner = true;
			this.filters = [filt];
			this.cacheAsBitmap = true;
		}
		
		public function notify():void{
			this.clockAngle=0;
		}
		
		public function start():void{
			this.clockAngle=0;
			this.remove = false;
			this.active= true;
		}
		
		public function stop():void{
			this.remove = true;
		}
		
		/**
		 * controls the remove clock on the bottem of the Prop
		 **/
		private function updateClock(evt:Event):void{
			var timeStep:Number = 360/this.stepCount;

			if(this.active){
				if(this.remove || (clockAngle > 359)){
					this.active = false;
				}else if(clockAngle < 370){
					
					//animates the clock
					clockAngle += timeStep;
					Tweener.addTween(this.rotationSprite, {x:clockAngle, time:0.01,
						onUpdate:function():void{
							var deg:Number = rotationSprite.x;
							if(deg > 30){
								clockPen.clear();
								clockPen.lineStyle(20, 0xb1b1b1, 1, false, "normal", "none", null, 3);
								clockPen.drawArc(0, 0, clockRadius, -deg, -90, false);
							}
						}
					});
				}
			}		
		}
	}
}