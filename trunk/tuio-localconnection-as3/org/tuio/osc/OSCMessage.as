﻿package org.tuio.osc {
	
	import flash.utils.ByteArray;
	
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
			for(var c:int = 0; c < this.pattern.length; c++){
				switch(this.pattern.charAt(c)){
					case "s": argumentArray.push(this.readString()); break;
					case "f": argumentArray.push(this.bytes.readFloat()); break;
					case "i": argumentArray.push(this.bytes.readInt()); break;
					case "b": argumentArray.push(this.readBlob()); break;
					default: break;
				}
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
		
	}
	
}