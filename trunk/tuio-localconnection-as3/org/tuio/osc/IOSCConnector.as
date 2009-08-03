package org.tuio.osc {
	
    interface IOSCConnector {
		
		public function addListener(listener:IOSCConnectorListener):void;
		
		public function removeListener(listener:IOSCConnectorListener):void;
		
		public function sendOSCPacket(oscPacket:OSCPacket):void;
		
    }
	
}