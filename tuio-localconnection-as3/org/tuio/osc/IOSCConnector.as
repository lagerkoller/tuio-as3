package org.tuio.osc {
	
    public interface IOSCConnector {
		
		function addListener(listener:IOSCConnectorListener):void;
		
		function removeListener(listener:IOSCConnectorListener):void;
		
		function sendOSCPacket(oscPacket:OSCPacket):void;
		
    }
	
}