package flash.events
{
	import flash.geom.Point;	
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import flash.display.DisplayObject;
	
	public class TUIOSimulator
	{	
		private var action:String;
		private var blobArray:Array;
		private var x:Number;
		private var y:Number;
		private var centerX:Number;
		private var centerY:Number;
		private var radius:Number;
		private var blobCount:int;
		private var updateTimer:Timer;
		private var deleteTimer:Timer;
		private var target:DisplayObject;
//---------------------------------------------------------------------------------------------------------------------------------------------
// CONSTRUCTOR
//---------------------------------------------------------------------------------------------------------------------------------------------
		public function TUIOSimulator($target:DisplayObject, $action:String, $x:Number, $y:Number, $count:int, $radius:Number)
		{
			target = $target;
			action = $action;
			x = $x; 
			y = $y; 
			centerX = $x;
			centerY = $y;	
			radius = $radius;
			blobCount = $count;

			var i:int;
			blobArray = new Array();
			for(i=0; i<blobCount; i++)
			{
				
				var to:TUIOObject = new TUIOObject("2DObj", int(Math.random()*65536), x + 2.0*(Math.random()-0.5)*radius, x + 2.0*(Math.random()-0.5)*radius, 0,0, -1, 0, 10, 10, target);
				to.addListener(target);
				to.notifyCreated();				
				blobArray.push(to);

			}
			
			updateTimer = new Timer(1000/30);
			updateTimer.addEventListener(TimerEvent.TIMER, updateBlobs);
			updateTimer.start();
			deleteTimer = new Timer(1000);
			deleteTimer.addEventListener(TimerEvent.TIMER, deleteMe);			
			deleteTimer.start();
			
		}
//---------------------------------------------------------------------------------------------------------------------------------------------
// PRIVATE METHODS
//---------------------------------------------------------------------------------------------------------------------------------------------
		private function updateBlobs(e:Event):void
		{
			var i:int;
			var m:Matrix;
			var p:Point;
			//trace("Updating");
		
			if(action == "0")
			{
			
				for(i=0; i<blobArray.length; i++)
				{
					m = new Matrix();
					p = new Point(blobArray[i].x - centerX, blobArray[i].y - centerY);
					m.rotate(Math.PI * 0.01);
					p = m.transformPoint(p);					
			    	blobArray[i].x = p.x + centerX;
					blobArray[i].y = p.y + centerY;					
					blobArray[i].notifyMoved();
				}
			}
			
			if(action == "1")
			{

				for(i=0; i<blobArray.length; i++)
				{
					m = new Matrix();
					p = new Point(blobArray[i].x - centerX, blobArray[i].y - centerY);
					m.scale(0.95, 0.95);
					p = m.transformPoint(p);
					blobArray[i].x = p.x + centerX;
					blobArray[i].y = p.y + centerY;
					blobArray[i].notifyMoved();
				}
			}
			
			if(action == "2")
			{
				for(i=0; i<blobArray.length; i++)
				{
					m = new Matrix();
					p = new Point(blobArray[i].x - centerX, blobArray[i].y - centerY);
					m.rotate(Math.PI * 0.01);
					m.scale(1.05, 1.05);					
					p = m.transformPoint(p);
					blobArray[i].x = p.x + centerX;
					blobArray[i].y = p.y + centerY;
					blobArray[i].notifyMoved();
				}
			}			
		}
//---------------------------------------------------------------------------------------------------------------------------------------------
		private function deleteMe(e:Event):void
		{
			for(var i:int=0; i<blobArray.length; i++)
			{
				blobArray[i].notifyRemoved();
			}			
			
			blobArray = null;
			updateTimer.removeEventListener(TimerEvent.TIMER, updateBlobs);
			deleteTimer.removeEventListener(TimerEvent.TIMER, deleteMe);
			updateTimer.stop();
			deleteTimer.stop();
			updateTimer = null;
			deleteTimer = null;
		}
//---------------------------------------------------------------------------------------------------------------------------------------------
	}
}