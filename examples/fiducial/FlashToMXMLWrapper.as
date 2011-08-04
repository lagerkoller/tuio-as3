package examples.fiducial
{
	import mx.core.UIComponent;
	
	/**
	 * Allows to include a Flash Sprite into a Flex application.
	 * In this example the multi-touch and TUI example app is being
	 * included.
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class FlashToMXMLWrapper extends UIComponent
	{
		private var fiducialTest:TUIOAS3FiducialExampleFlash;
		
		public function FlashToMXMLWrapper()
		{
			super();
		}
				
		/**
		 * initializes the Flash Sprite. In createChildren() of UIComponent (and ONLY 
		 * here) DisplayObject that do inherit from DisplayObject but do NOT inherit
		 * from UIComponent may be added to a UIComponent.
		 * 
		 */
		override protected function createChildren():void{
			if(!fiducialTest){
				fiducialTest = new TUIOAS3FiducialExampleFlash();
				addChild(fiducialTest);
			}
		}
		
	}
}