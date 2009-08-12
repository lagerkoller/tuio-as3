package org.tuio.osc {
	
	public class OSCManager implements IOSCConnectorListener {
		
		private var connIn:IOSCConnector;
		private var connOut:IOSCConnector;
		
		private var currentPacket:OSCPacket;
		
		private var msgListener:Array;
		private var oscMethods:Array;
		
		public function OSCManager() {
			
			this.msgListener = new Array();
			this.oscMethods = new Array();
			
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
			this.multicastOSCPacket(this.currentPacket);
		}
		
		private function multicastOSCPacket(packet:OSCPacket) {
			if (packet is OSCMessage) {
				this.multicastOSCMessage(packet);
			} else if (packet is OSCBundle) {
				var cont:Array = (packet as OSCBundle).subPackets.concat();
				
				for each(var p:OSCPacket in cont) {
					this.multicastOSCPacket(p);
				}
			}
		}
		
		private function multicastOSCMessage(msg:OSCMessage) {

			for each(var l:IOSCListener in this.msgListener) {
				l.acceptOSCMessage(msg);
			}
			
			if(this.oscMethods.length > 0){
				var oscMethod:IOSCListener = this.oscMethods[msg.addressPattern];
			
				if (oscMethod != null) oscMethod.acceptOSCMessage(msg);
			}
			
		}
		
		public function addMethod(address:String, listener:IOSCListener):void {
			this.oscMethods[address] = listener;
		}
		
		public function addMsgListener(listener:IOSCListener):void {
			
			if (this.msgListener.indexOf(listener) > -1) return;
			
			this.msgListener.push(listener);
		}
	}
	
}