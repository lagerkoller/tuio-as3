package org.tuio.osc {
	
	public class OSCManager implements IOSCConnectorListener {
		
		private var connIn:IOSCConnector;
		private var connOut:IOSCConnector;
		
		private var currentPacket:OSCPacket;
		
		private var msgListener:Array;
		private var oscMethods:Array;
		private var oscAddressSpace:OSCAddressSpace;
		
		public var usePatternMatching:Boolean = false;
		
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
			this.distributeOSCPacket(this.currentPacket);
		}
		
		private function distributeOSCPacket(packet:OSCPacket) {
			if (packet is OSCMessage) {
				this.distributeOSCMessage(packet);
			} else if (packet is OSCBundle) {
				var cont:Array = (packet as OSCBundle).subPackets.concat();
				
				for each(var p:OSCPacket in cont) {
					this.distributeOSCPacket(p);
				}
			}
		}
		
		private function distributeOSCMessage(msg:OSCMessage) {

			for each(var l:IOSCListener in this.msgListener) {
				l.acceptOSCMessage(msg);
			}
			
			if(this.oscMethods.length > 0){
				
				var oscMethod:IOSCListener;
				var oscMethods:Array;
				
				if (this.usePatternMatching) {
					oscMethods = this.oscAddressSpace.getMethods(msg.addressPattern);
					for each(var l:IOSCListener in oscMethods) {
						l.acceptOSCMessage(msg);
					}
				} else {
					oscMethod = this.oscMethods[msg.addressPattern];
					if (oscMethod != null) oscMethod.acceptOSCMessage(msg);
				}
			}
			
		}
		
		public function addMethod(address:String, listener:IOSCListener):void {
			this.oscMethods[address] = listener;
			this.oscAddressSpace.addMethod(address, listener);
		}
		
		public function addMsgListener(listener:IOSCListener):void {
			
			if (this.msgListener.indexOf(listener) > -1) return;
			
			this.msgListener.push(listener);
		}
		
	}
	
}