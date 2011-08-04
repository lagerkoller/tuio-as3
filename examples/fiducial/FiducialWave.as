package examples.fiducial
{
	import examples.fiducial.caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.utils.Timer;

	/**
	 * A wave animation that will be shown e.g. around a fiducial.
	 *  
	 * @author johannes
	 * 
	 */
	public class FiducialWave extends Sprite
	{
		private var wave:Sprite;
		private var waveTimer:Timer;
		private var stopAnimation:Boolean;

		private var innerWaveRadius:Number;		
		private var lineColor:Number;
		private var duration:Number;
		private var disappearDuration:Number;

		public function FiducialWave(innerWaveRadius:Number,
										lineColor:Number = 0,
										duration:Number = 3000, 
										disappearDuration:Number = 500)
		{
			super();
			this.duration = duration/1000;
			this.disappearDuration = disappearDuration/1000;
			
			wave = new Sprite();
			wave.alpha = 0.5;
			wave.graphics.clear();
			wave.graphics.lineStyle(1,lineColor);
			wave.graphics.drawCircle(0,0,innerWaveRadius);
			this.addChild(wave);
		}
		public function startWave():void{
			this.wave.visible = true;
			stopAnimation = false;
			animateWave();
		}		
		public function stopWave():void{
			this.wave.visible = false;
			stopAnimation = true;
		}
		private function animateWave():void{
			wave.scaleX = 3;
			wave.scaleY = 3;
			wave.alpha = 0;
			Tweener.addTween(wave,
							{alpha:0.5, scaleX:1, scaleY:1, time:duration,
								onComplete:function():void{
									Tweener.addTween(wave,{alpha:0.0, time:disappearDuration,
																onComplete:function():void{
																	if(!stopAnimation){
																		animateWave();
																	}
																}
															});							
								}
							});
		}
		
	}
}