package org.tuio.osc {
	
	import flash.utils.ByteArray;
	import org.tuio.lc.*;
	
	public class LCConnector implements IOSCConnector {
		
		private var connectionNameIn:String;
		private var connectionNameOut:String;
		
		private var connectionOut:LCSender;
		private var connectionIn:LCReceiver;
		
		private var listeners:Array;
		
		public function LCConnector(connectionNameIn:String = "_OscDataStream", connectionNameOut:String = "_OscDataStreamOut", receivingMethodName:String = "receiveOscData") {
			
			this.connectionNameIn = connectionNameIn;
			this.connectionNameOut = connectionNameOut;
			
			this.connectionIn = new LCReceiver(this.connectionNameIn, this);
			this.connectionOut = new LCSender(this.connectionNameOut);
			
			this.connectionIn.start();
		}
		
		public function receiveOscData(packet:ByteArray) {
			if (packet != null) {
				if (this.listeners.length > 0) {
					//call receive listeners and push the received messages
					for each(var l:IOSCConnectorListener in this.listeners) {
						if (OSCBundle.isBundle(packet)) {
							l.acceptOSCPacket(new OSCBundle(packet));
						} else if (OSCMessage.isMessage(packet)) {
							l.acceptOSCPacket(new OSCMessage(packet));
						} else {
							this.debug("\nreceived: invalid osc packet.");
						}
					}
				}
			}
		}
		
		public function addListener(listener:IOSCConnectorListener):void {
			
			for each(var l:Object in this.listeners) {
				if (l == listener) {
					debug("Listener already added.");
					return;
				}
			}
			
			this.listeners.push(listener);
			
		}
		
		public function removeListener(listener:IOSCConnectorListener):void {
			
			var tmp:Array = this.listeners.concat();
			var newList:Array = new Array();
			
			var item:Object = tmp.pop();
			while (item != null) {
				if (item != listener) newList.push(item);
			}
			
			this.listeners = newList;
			
		}
		
		public function sendOSCPacket(oscPacket:OSCPacket):void {
			
			this.connectionOut.send(oscPacket);
			
		}
		
		private function debug(msg:String):void {
			trace(msg);
		}
		
	}
	
}
	