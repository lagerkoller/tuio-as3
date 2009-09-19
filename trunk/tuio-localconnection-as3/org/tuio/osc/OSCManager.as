package org.tuio.osc {
	
	public class OSCManager implements IOSCConnectorListener {
		
		private var connIn:IOSCConnector;
		private var connOut:IOSCConnector;
		
		private var currentPacket:OSCPacket;
		
		private var msgListener:Array;
		private var oscMethods:Array;
		private var oscAddressSpace:OSCAddressSpace;
		
		private var running:Boolean;
		
		public var usePatternMatching:Boolean = false;
		
		public function OSCManager(connectorIn:IOSCConnector = null, connectorOut:IOSCConnector = null, autoStart:Boolean = true) {
			
			this.msgListener = new Array();
			this.oscMethods = new Array();
			
			this.connIn = connectorIn;
			if(this.connIn != null) this.connIn.addListener(this);
			this.connOut = connectorOut;
			
			this.running = autoStart;
			
		}
		
		public function start():void {
			this.running = true;
		}

		public function stop():void {
			this.running = false;
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
			this.connOut.sendOSCPacket(oscPacket);
		}
		
		public function getCurrentPacket():OSCPacket {
			return this.currentPacket;
		}
		
		public function acceptOSCPacket(oscPacket:OSCPacket):void {
			if(running){
				this.currentPacket = oscPacket;
				this.distributeOSCPacket(this.currentPacket);
			}
		}
		
		private function distributeOSCPacket(packet:OSCPacket):void {
			if (packet is OSCMessage) {
				this.distributeOSCMessage(packet as OSCMessage);
			} else if (packet is OSCBundle) {
				var cont:Array = (packet as OSCBundle).subPackets.concat();
				for each(var p:OSCPacket in cont) {
					this.distributeOSCPacket(p);
				}
			}
		}
		
		private function distributeOSCMessage(msg:OSCMessage):void {

			for each(var l:IOSCListener in this.msgListener) {
				l.acceptOSCMessage(msg);
			}
			
			if(this.oscMethods.length > 0){
				
				var oscMethod:IOSCListener;
				var oscMethods:Array;
				
				if (this.usePatternMatching) {
					oscMethods = this.oscAddressSpace.getMethods(msg.addressPattern);
					for each(l in oscMethods) {
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
		
		public function removeMethod(address:String):void {
			this.oscMethods[address] = null;
			this.oscAddressSpace.removeMethod(address);
		}
		
		public function addMsgListener(listener:IOSCListener):void {
			if (this.msgListener.indexOf(listener) > -1) return;
			this.msgListener.push(listener);
		}
		
		public function removeMsgListener(listener:IOSCListener):void {
			var temp:Array = new Array();
			for each(var l:IOSCListener in this.msgListener) {
				if (l != listener) temp.push(l);
			}
			this.msgListener = temp.concat();
		}
		
	}
	
}