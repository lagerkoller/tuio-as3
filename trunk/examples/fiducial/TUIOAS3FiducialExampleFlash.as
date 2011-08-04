package examples.fiducial
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class TUIOAS3FiducialExampleFlash extends Sprite
	{
		public function TUIOAS3FiducialExampleFlash()
		{
			super();
			      
			//fiducial test listener
			var fiducialTest:FiducialCallbackTest = new FiducialCallbackTest();
			fiducialTest.fiducialId = 1;
			addChild(fiducialTest);
			
			var fiducialEventListenerTest:FiducialEventListenerTest = new FiducialEventListenerTest();
			addChild(fiducialEventListenerTest);
		}
		
	}
}