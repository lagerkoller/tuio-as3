package examples.fiducial
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.tuio.TuioFiducialEvent;
	
	/**
	 * If a fiducial is being added on top of this FiducialEventListenerTest instance the green rect 
	 * will cling to this fiducial until fiducial is removed.
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class FiducialEventListenerTest extends Sprite
	{
		private var fiducialId:Number;
		private var localX:Number;
		private var localY:Number;
		
		/**
		 *  
		 * 
		 */
		public function FiducialEventListenerTest()
		{
			super();
			this.graphics.beginFill(0xCEED90);
			this.graphics.drawRoundRect(0,0,250,150, 20, 20);
			this.graphics.endFill();
			this.x = 0;
			this.y = 100;
			
			var filt:DropShadowFilter = new DropShadowFilter();
			filt.angle = 90;
			filt.blurX = 10;
			filt.blurY = 10;
			filt.distance = 5;
			filt.color = 0x787878;
			this.filters = [filt];
			this.cacheAsBitmap = true;
			
			addHintText();
			
			this.addEventListener(TuioFiducialEvent.ADD, fiducialAdd);
		}
		
		private function fiducialAdd(event:TuioFiducialEvent):void{
			fiducialId = event.fiducialId;
			localX = event.localX;
			localY = event.localY;
			
			stage.addEventListener(TuioFiducialEvent.MOVE, fiducialMove);
			stage.addEventListener(TuioFiducialEvent.REMOVED, fiducialRemoved);
		}
		private function fiducialMove(event:TuioFiducialEvent):void{
			if(event.fiducialId == fiducialId){
				this.x = event.x - localX;
				this.y = event.y - localY;
			}
		}
		private function fiducialRemoved(event:TuioFiducialEvent):void{
			stage.removeEventListener(TuioFiducialEvent.MOVE, fiducialMove);
			stage.removeEventListener(TuioFiducialEvent.REMOVED, fiducialRemoved);
		}
		
		/**
		 * adds text to this FiducialEventListenerTest instance.
		 * 
		 */
		private function addHintText():void{
			//draw objectid label
			var fiducialEventTestLabel:TextField = new TextField();
			fiducialEventTestLabel.autoSize = TextFieldAutoSize.LEFT;
			fiducialEventTestLabel.background = false;
			fiducialEventTestLabel.border = false;
			fiducialEventTestLabel.multiline = true;
			fiducialEventTestLabel.wordWrap = true;
			fiducialEventTestLabel.width = 220;
			fiducialEventTestLabel.text = "Test FiducialEvents: Put any fiducial on top of me and drag it.";
			fiducialEventTestLabel.defaultTextFormat = fiducialTestTextFormat();
			fiducialEventTestLabel.setTextFormat(fiducialTestTextFormat());
			
			var translationX:Number = 0.5*fiducialEventTestLabel.width;
			var translationY:Number = 10+0.5*fiducialEventTestLabel.height;
			//copy TextField into a bitmap
			var typeTextBitmap : BitmapData = new BitmapData(fiducialEventTestLabel.width, 
				fiducialEventTestLabel.height,true,0x00000000);
			typeTextBitmap.draw(fiducialEventTestLabel);
			
			//calculate center of TextField
			var typeTextTranslationX:Number = -0.5*fiducialEventTestLabel.width+translationX+5;
			var typeTextTranslationY:Number = -0.5*fiducialEventTestLabel.height+translationY-5;
			
			//create Matrix which moves the TextField to the center
			var matrix:Matrix = new Matrix();
			matrix.translate(typeTextTranslationX, typeTextTranslationY);
			
			//actually draw the text on the stage (with no-repeat and anti-aliasing)
			this.graphics.beginBitmapFill(typeTextBitmap,matrix,false,true);
			this.graphics.lineStyle(0,0,0);
			this.graphics.drawRect(typeTextTranslationX, typeTextTranslationY, 
				fiducialEventTestLabel.width, fiducialEventTestLabel.height);
			this.graphics.endFill();
		}
		
		/**
		 *  
		 * @return
		 * 
		 */
		private function fiducialTestTextFormat():TextFormat{
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.color = 0x0;
			format.size = 12;
			format.underline = false;
			format.bold = true;
			
			return format;
		}
	}
}