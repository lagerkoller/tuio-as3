package org.tuio.osc {
	
	import flash.utils.ByteArray;
	import flash.errors.EOFError;
	
	/**
	 * An OSCMessage
	 * @author Immanuel Bauer
	 */
	public class OSCMessage extends OSCPacket {
		
		private var address:String;
		private var pattern:String;
		private var action:String;
		private var argumentArray:Array;
		
		/**
		 * Creates a OSCMessage from the given ByteArray containing a binarycoded OSCMessage
		 * 
		 * @param	bytes A ByteArray containing an OSCMessage
		 */
		public function OSCMessage(bytes:ByteArray) {
			super(bytes);
			
			//read the OSCMessage head
			this.address = this.readString();
			
			//read the parsing pattern for the following OSCMessage bytes
			this.pattern = this.readString();
			
			this.argumentArray = new Array();
			
			//read the remaining bytes according to the parsing pattern
			var innerArray:Array;
			var openArray:Array = this.argumentArray;
			try{
				for(var c:int = 0; c < this.pattern.length; c++){
					switch(this.pattern.charAt(c)){
						case "s": openArray.push(this.readString()); break;
						case "f": openArray.push(this.bytes.readFloat()); break;
						case "i": openArray.push(this.bytes.readInt()); break;
						case "b": openArray.push(this.readBlob()); break;
						case "h": openArray.push(this.read64BInt()); break;
						case "t": openArray.push(this.readTimetag()); break;
						case "d": openArray.push(this.bytes.readDouble()); break;
						case "S": openArray.push(this.readString()); break;
						case "c": openArray.push(this.bytes.readMultiByte(4, "US-ASCII")); break;
						case "r": openArray.push(this.readUnsignedInt()); break;
						case "T": openArray.push(true); break;
						case "F": openArray.push(false); break;
						case "N": openArray.push(null); break;
						case "I": openArray.push(Infinity); break;
						case "[": innerArray = new Array(); openArray = innerArray; break;
						case "]": this.argumentArray.push(innerArray.concat()); openArray = this.argumentArray; break;
						default: break;
					}
				}
			} catch (e:EOFError) {
				this.argumentArray = new Array();
				this.argumentArray.push("Corrupted OSCMessage");
				openArray = null;
			}
		}
		
		/**
		 * @return The address pattern of the OSCMessage
		 */
		public function get addressPattern():String {
			return address;
		}
		
		/**
		 * @return The arguments/content of the OSCMessage
		 */
		public function get arguments():Array {
			return argumentArray;
		}
		
		/**
		 * Generates a String representation of this OSCMessage for debugging purposes
		 * 
		 * @return A traceable String.
		 */
		public override function getPacketInfo():String {
			var out:String = new String();
			out += "\nMessagehead: " + this.address + " | " + this.pattern + " | ->  (" + this.argumentArray.length + ") \n" + this.argumentsToString() ;
			return out;
		}
		
		/**
		 * Generates a String representation of this OSCMessage's content for debugging purposes
		 * 
		 * @return A traceable String.
		 */
		public function argumentsToString():String{
			var out:String = "arguments: ";
			out += this.argumentArray[0].toString();
			for(var c:int = 1; c < this.argumentArray.length; c++){
				out += " | " + this.argumentArray[c].toString();
			}
			return out;
		}
		
		/**
		 * Checks if the given ByteArray is an OSCMessage
		 * 
		 * @param	bytes The ByteArray to be checked.
		 * @return true if the ByteArray contains an OSCMessage
		 */
		public static function isMessage(bytes:ByteArray) {
			if (bytes != null) {
				bytes.position = 0;
				var header:String = bytes.readUTFBytes(1);
				bytes.position = 0;
				if (header == "/") {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
	}
	
}