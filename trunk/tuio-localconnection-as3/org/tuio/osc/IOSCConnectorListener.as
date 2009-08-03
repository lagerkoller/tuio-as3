package org.tuio.osc {
	
    interface IOSCConnectorListener {
		
		public function acceptOSCPacket(oscPacket:OSCPacket):void;
		
    }
	
}