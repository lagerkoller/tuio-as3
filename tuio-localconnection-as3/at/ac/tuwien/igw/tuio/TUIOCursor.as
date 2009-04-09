package at.ac.tuwien.igw.tuio {
	
	import flash.display.Sprite;

	internal class TUIOCursor extends Sprite {
		
		public function TUIOCursor(text:int, color:int, pressure:Number, width:Number, height:Number){
			super();
			if (TUIO.debug) { 			
				this.blendMode="invert";
				this.graphics.lineStyle( 0, 0x000000);	
				this.graphics.drawCircle(0 ,0, 15);			
			} else {			
				this.graphics.clear();
			}	
		}
		
	}
}