package at.ac.tuwien.igw.osc {

	import flash.utils.ByteArray;
	import flash.net.LocalConnection;
	
	/**
	 * A class for receiving and parsing OSCPackets 
	 * 
	 * @author Immanuel Bauer
	 */
	public class OSCReceiver {
		
		private var lastPacket:OSCPacket;
		private var listener:Function;
		private var localConnectionName:String;
		private var localConnection:LocalConnection;
		
		public function OSCReceiver(lcName:String) {
			this.localConnectionName = lcName;
		}
		
		public function receiveOscData(bytes:ByteArray):void {
			this.lastPacket = new OSCBundle(bytes);
		}
		
		public function debugTraceString():String {
			return lastPacket.getPacketInfo();
		}
		
		public function start():Boolean {
			try {
				this.stop();
				this.localConnection = new LocalConnection();
				
				this.localConnection.allowDomain('*');
				this.localConnection.client = this;
				this.localConnection.connect(this.localConnectionName);
				
				return true;
			} catch (e:Error) {
				return false;
			}
			return false;
		}
		
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
		
		public function addReceiveListener(l:Function):void {
			this.listener = l;
		}
		
	}
	
}