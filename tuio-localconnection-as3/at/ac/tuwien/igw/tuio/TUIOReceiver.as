package at.ac.tuwien.igw.tuio {
	
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.net.LocalConnection;
	import at.ac.tuwien.igw.osc.*;
	import flash.events.StatusEvent;
	
	/**
	 * A Class for receiving TUIO messages via LocalConnection
	 * @author Immanuel Bauer
	 */
	public class TUIOReceiver {
		
		private var listener:Function;
		private var debugListener:Function;
		private var currentPacket:OSCBundle;
		private var localConnection:LocalConnection;
		
		public function TUIOReceiver() {
			var fv:String = Capabilities.version;
			var fvp:Array = fv.split(" ");
			fvp = fvp[1].split(",");
			if(fvp[0] < 10){
				trace("Warning: To guarantee most stable functionality you should at least use flash v10!\nYou have: "+fv);
				
				debug("Warning: To guarantee most stable functionality you should at least use flash v10!\nYou have: "+fv);
			}
			
			super();
		}
		
		/**
		 * Creates a localconnection to "listen" for TUIO packets
		 * 
		 * @return true if connected successfully
		 */
		public function start():Boolean {
			this.stop();
			
			this.localConnection = new LocalConnection();
			this.localConnection.allowDomain('*');
			this.localConnection.client = this;
			
			var testLC:LocalConnection = new LocalConnection();
			testLC.allowDomain('*');
			
			var retry:int = 0;
			
			while(retry < 8){
				try {
					
					this.localConnection.connect("_TuioOscDataStream"+retry.toString());
			
					try {
						testLC.connect("_TuioOscDataStream"+retry.toString());
						retry++;
						debug("retry");
					} catch (e:Error){
						debug("connected as: _TuioOscDataStream"+retry.toString());
						return true;
					}
					
				} catch (e:Error) {
					retry++;
					debug("retry");
				}
			}
			
			return false;
		}
		
		/**
		 * Stops the localconnection
		 * 
		 * @return true if the localconnection could be stopped
		 */
		public function stop():Boolean {
			try {
				if (this.localConnection != null) {
					this.localConnection.close();
				}
				return true;
			} catch (e:Error) {
				return false;
			}
			return false;
		}
		
		/**
		 * This function has to be called in order to let the receiver receive its TUIO Events.
		 * Usually this function is called via the localconnection by a tracker but can also be 
		 * called directly for debugging purposes.
		 * 
		 * @param	packet A ByteArray that contains the content of a TUIO packet
		 */
		public function receiveTuioOscData(packet:ByteArray):void {
			if (packet != null) {
				if (OSCBundle.isBundle(packet)) {
					//parse received ByteArray and create a bundle
					this.currentPacket = new OSCBundle(packet);
					
					this.debug("\nreceived:" + this.currentPacket.getPacketInfo());
					
					if (this.listener != null) {
						var msgArray:Array = new Array();
						//check received bundle for messages
						for each(var item in this.currentPacket.subPackets) {
							if (item is OSCMessage) msgArray.push(item);
						}
						//call receive listener and push the received messages
						this.listener.call(NaN, msgArray);
					}
				} else {
					this.debug("\nreceived: invalid tuio packet.");
				}
			}
		}
		
		private function debug(msg:String):void {
			if (this.debugListener != null) {
				this.debugListener.call(NaN, msg);
			}
		}
		
		//TODO: possibly port listener to as3 event model
		
		/**
		 * Sets the receivelistener. A Function that is called when a TUIO Packet is received 
		 * and parsed successfully.
		 * The function hast to accept an Array as paramter which will contain the parsed
		 * TUIO packet content.
		 * 
		 * @param	l The listener Function(params: Array).
		 */
		public function setReceiveListener(l:Function):void {
			this.listener = l;
		}
		
		/**
		 * Sets the debuglistener. A Function that is called when the TUIOReceiver needs to trace
		 * a debug message to avoid unwanted trace output.
		 * The function hast to accept a String that contains the message.
		 * 
		 * @param	l The listener Function(params: String).
		 */
		public function setDebugListener(l:Function):void {
			this.debugListener = l;
		}
		
	}
	
}