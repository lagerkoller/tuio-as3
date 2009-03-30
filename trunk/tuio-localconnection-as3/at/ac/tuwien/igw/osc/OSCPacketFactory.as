package at.ac.tuwien.igw.osc {
	
	import flash.utils.ByteArray;
	
	/**
	 * OSCPacket Factory
	 * creates an OSCPacket from a OSC byte stream
	 * @author Immanuel Bauer
	 */
	public class  OSCPacketFactory {
		
		public static function getOSCPacket(bytes:ByteArray):OSCPacket {
			
			bytes.position = 0;
			
			try{
				out = bytes.readUTFBytes(8);
				if (out == "#bundle") {
					return getOSCBundle(bytes)
				} else {
					return getOSCMessage(bytes);
				}
			} catch(e:EOFError) {
				return null;
			}
			return null;
		}
		
		private function getOSCBundle(bytes:ByteArray):OSCBundle {
			
		}
		
		private function getOSCMessage(bytes:ByteArray):OSCMessage {
			bytes.position = 0;
		}
		
	}
	
}