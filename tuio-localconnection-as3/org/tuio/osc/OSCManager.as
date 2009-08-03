package org.tuio.osc {
	
	public class OSCManager implements IOSCConnectorListener {
		
		private var connIn:IOSCConnector;
		private var connOut:IOSCConnector;
		
		private var currentPacket:OSCPacket;
		
		public function OSCManager() {
			
			
			
		}
		
		public function setConnectorIn(conn:IOSCConnector):void {
			if (this.connIn != null) {
				this.connIn.removeListener(this);
			}
			this.connIn = conn;
			this.connIn.addListener(this);
		}
		
		public function setConnectorOut(conn:IOSCConnector):void {
			this.connOut = conn;
		}
		
		public function sendOSCPacket(oscPacket:OSCPacket):void {
			this.connOut.sendPacket(oscPacket);
		}
		
		public function getCurrentPacket():OSCPacket {
			return this.currentPacket;
		}
		
		public function acceptOSCPacket(oscPacket:OSCPacket):void {
			this.currentPacket = oscPacket;
		}
		
	}
	
}