package examples.fiducial
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.tuio.ITuioFiducialReceiver;
	import org.tuio.TuioFiducialEvent;
	import org.tuio.TuioManager;
	
	/**
	 * FiducialTest implements the interface ITuioFiducialReceiver. Whenever a fidcuial with
	 * the id _fiducialId is being added to the Tuio objects (e.g. via the Tuio Simulator or
	 * on your tabletop) _debugSprite will be added to stage. 
	 * 
	 * In FiducialTest _debugSprite is just a red rect with a few debug information. Additionally,
	 * for animation purposes a wave will be animated around _debugSprite. If onNotifyRemoved is 
	 * being called a clock animation will be shown in the center of _debugSprite.
	 * 
	 * BEWARE: This example only supports one fiducial with the id _fiducialId. If more than one 
	 * fiducial with _fiducialId should be used, this has to be handled appropriately.
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class FiducialCallbackTest extends Sprite implements ITuioFiducialReceiver{
		private var _fiducialId:Number = -1;
		private var _debugSprite:Sprite;
		
		private var fiducialClock:FiducialClock;
		
		public function FiducialCallbackTest(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			_debugSprite = new Sprite();
			configureDebugObject();
		}
		
		/**
		 * registers this FiducialTest instance as a callback for the fiducial with the fiducial id 
		 * _fiducialId with TuioFiducialDispatcher.
		 *  
		 * @param event enter frame event.
		 * 
		 */
		private function addedToStage(event:Event):void{
			if(_fiducialId >= 0){
				TuioManager.getInstance().registerFiducialReceiver(this,_fiducialId);
				addHintTextToStage();
			}
		}
		
		private function addHintTextToStage():void{
			var touchTestLabel:TextField = new TextField();
			touchTestLabel.autoSize = TextFieldAutoSize.LEFT;
			touchTestLabel.background = false;
			touchTestLabel.border = false;
			touchTestLabel.text = "Test fiducial callbacks: Put a fiducial with Id "+this._fiducialId+" onto stage.";
//			touchTestLabel.width/2+5;
			touchTestLabel.defaultTextFormat = fiducialTestTextFormat();
			touchTestLabel.setTextFormat(fiducialTestTextFormat());
			
			var translationX:Number = 0.5*touchTestLabel.width;
			var translationY:Number = 0.5*touchTestLabel.height;
			
			//copy TextField into a bitmap
			var typeTextBitmap : BitmapData = new BitmapData(touchTestLabel.width, 
				touchTestLabel.height,true,0x00000000);
			typeTextBitmap.draw(touchTestLabel);
			
			//calculate center of TextField
			var typeTextTranslationX:Number = -0.5*touchTestLabel.width+translationX+5;
			var typeTextTranslationY:Number = -0.5*touchTestLabel.height+translationY-5;
			
			//create Matrix which moves the TextField to the center
			var matrix:Matrix = new Matrix();
			matrix.translate(typeTextTranslationX, typeTextTranslationY);
			
			var textSprite:Sprite = new Sprite();
			//actually draw the text on the stage (with no-repeat and anti-aliasing)
			textSprite.graphics.beginBitmapFill(typeTextBitmap,matrix,false,true);
			textSprite.graphics.lineStyle(0,0,0);
			textSprite.graphics.drawRect(typeTextTranslationX, typeTextTranslationY, 
				touchTestLabel.width, touchTestLabel.height);
			textSprite.graphics.endFill();
			stage.addChild(textSprite);
			textSprite.x = 10;
			textSprite.y = 10;
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
		
		/**
		 * 
		 * @return current fiducial id that is being registered with TuioManager.  
		 * 
		 */
		public function get fiducialId():Number{
			return _fiducialId;
		}
		
		/**
		 * registers a new fiducial id with TuioManager and removes the old fiducial id
		 * callback. 
		 * 
		 * @param fiducialId on which this FiducialTest instance should be registered as a callback 
		 * with TuioManager. 
		 * 
		 */
		public function set fiducialId(fiducialId:Number):void{
			if(stage != null){
				TuioManager.getInstance().removeFiducialReceiver(this,_fiducialId);
				TuioManager.getInstance().registerFiducialReceiver(this,fiducialId);
			}
			_fiducialId = fiducialId;
			configureDebugObject();
		}
		
		public function onAdd(evt:TuioFiducialEvent):void{
			this.x = evt.x;
			this.y = evt.y;
			addChild(_debugSprite);
		}
		
		/**
		 *shows a fiducial clock animation in the center of _debugSprite that lasts timeout ms.
		 * 
		 * @param evt fiducial event
		 * @param timeout time until onRemove will be called (if not onNotifyReturned is being called before).
		 * 
		 */
		public function onNotifyRemoved(evt:TuioFiducialEvent, timeout:Number):void
		{
			this.fiducialClock = new FiducialClock(timeout, stage.frameRate, 30);
			_debugSprite.addChild(this.fiducialClock);
			this.fiducialClock.start();
		}
		
		
		/**
		 *removes clock animation from _debugSprite.
		 * 
		 * @param evt
		 * 
		 */
		public function onNotifyReturned(evt:TuioFiducialEvent):void
		{
			_debugSprite.removeChild(this.fiducialClock);
		}
		
		
		/**
		 *removes the _debugSprite from stage.
		 *  
		 * @param evt
		 * 
		 */
		public function onRemove(evt:TuioFiducialEvent):void
		{
			_debugSprite.removeChild(this.fiducialClock);
			removeChild(_debugSprite);
		}
		
		/**
		 *adjusts the position of this FiducialTest instance on stage.
		 *  
		 * @param evt
		 * 
		 */
		public function onMove(evt:TuioFiducialEvent):void
		{
			this.x = evt.x;
			this.y = evt.y;
		}
		
		/**
		 * rotates this FiducialTest instance on stage.
		 * @param evt
		 * 
		 */
		public function onRotate(evt:TuioFiducialEvent):void
		{
			this.rotation = evt.rotation;
		}
		
		/**
		 * initializes _debugSprite. 
		 * 
		 */
		public function configureDebugObject():void{
			var objectId:Number = _fiducialId; 
			var objectWidth:Number = 100; 
			var objectHeight:Number = 100; 
			var objectColor:Number = 0xff0000; 
			var objectAlpha:Number = 0.4; 
			var lineThickness:Number = 3;
			var lineColor:Number = 0x0;
			var lineAlpha:Number = 1;
			
			//draw object rect
			_debugSprite.graphics.clear();
			_debugSprite.graphics.beginFill(objectColor);
			_debugSprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
//			_debugSprite.graphics.drawRect(-0.5*objectWidth, -0.5*objectHeight, objectWidth,objectHeight);
			_debugSprite.graphics.drawCircle(0,0, objectWidth/2+10);
			_debugSprite.graphics.endFill();
			
			//draw direction line
			_debugSprite.graphics.lineStyle(3, 0x0, 1);
			_debugSprite.graphics.moveTo(0,0);
			_debugSprite.graphics.lineTo(0,-0.5*objectHeight+5);
			
			//draw objectid label
			var objectIdLabel:TextField = new TextField();
            objectIdLabel.autoSize = TextFieldAutoSize.LEFT;
            objectIdLabel.background = false;
            objectIdLabel.border = false;
			objectIdLabel.text = ""+objectId;
			objectIdLabel.width/2+5;
            objectIdLabel.defaultTextFormat = objectIdTextFormat();
            objectIdLabel.setTextFormat(objectIdTextFormat());
            
            var translationX:Number = -0.5*objectWidth+0.5*objectIdLabel.width;
            var translationY:Number = 0.5*objectHeight-0.5*objectIdLabel.height;
            //copy TextField into a bitmap
			var typeTextBitmap : BitmapData = new BitmapData(objectIdLabel.width, 
			                                objectIdLabel.height,true,0x00000000);
			typeTextBitmap.draw(objectIdLabel);
			 
			//calculate center of TextField
			var typeTextTranslationX:Number = -0.5*objectIdLabel.width+translationX+5;
			var typeTextTranslationY:Number = -0.5*objectIdLabel.height+translationY-5;
			 
			//create Matrix which moves the TextField to the center
			var matrix:Matrix = new Matrix();
			matrix.translate(typeTextTranslationX, typeTextTranslationY);
			
			//actually draw the text on the stage (with no-repeat and anti-aliasing)
			_debugSprite.graphics.beginBitmapFill(typeTextBitmap,matrix,false,true);
			_debugSprite.graphics.lineStyle(0,0,0);
			_debugSprite.graphics.drawRect(typeTextTranslationX, typeTextTranslationY, 
			                                objectIdLabel.width, objectIdLabel.height);
			_debugSprite.graphics.endFill();
		}
		
		/**
		 *sets the TextFormat for _debugSprite's debug text.
		 *  
		 * @return the TextFormat for _debugSprite's debug text.
		 * 
		 */
		private function objectIdTextFormat():TextFormat{
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.color = 0xffffff;
            format.size = 11;
            format.underline = false;
	            
        	return format;
		}
	}
}