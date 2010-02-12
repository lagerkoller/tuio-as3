/**
 * Currently UDP in Adobe Air is only supported in Air 2 beta. Additionally, this connector 
 * only works under Windows and NOT with Mac OS X.
 * 
 * I tested it with Air 2 beta 2 and it did NOT work under Mac OS X 10.5 as I regularly 
 * got a "VerifyError: Error #1014: Class flash.net::DatagramSocket could not be found."
 * in adl, which i didn't get under Windows with the same combination.  
 * 
 * This seems to be a bug of the beta version and I filed the bug in Adobe's bug tracking 
 * system. Hopefully it will be mended soon.
 * 
 * This function is currently only supported in Adobe Air 2 beta. Thus, as long as
 * Air 2 is still beta following arrangements have to be made in your app to use 
 * UDPConnector:
 * 1. Download Adobe Air 2 Beta from Adobe: http://labs.adobe.com/technologies/air2/ 
 * 2. Install it: http://labs.adobe.com/wiki/index.php/AIR_2:Release_Notes#How_to_overlay_the_Adobe_AIR_SDK_for_use_with_the_Flex_SDK
 * 3. Set the SDK of your project to the SDK that supports Air 2.
 * 4. If your updating an existing App don't forget to adjust the namespace in your
 * app descriptor to "http://ns.adobe.com/air/application/2.0beta2" otherwise you will
 * get the VerifyError as well under Windows.
 * 
 * To use UDPConnector in your app do something like the following:
 * 
 * var tuio:TuioClient = new TuioClient(new UDPConnector());
 * or  
 * var tuio:TuioClient = new TuioClient(new UDPConnector("192.0.0.5"));
 * or
 * var tuio:TuioClient = new TuioClient(new UDPConnector("192.0.0.5",3334));
 */
package org.tuio.udp
{
	import flash.utils.ByteArray;
	
	import org.tuio.osc.IOSCConnector;
	import org.tuio.osc.IOSCConnectorListener;
	import org.tuio.osc.OSCBundle;
	import org.tuio.osc.OSCMessage;
	import org.tuio.osc.OSCPacket;
	import org.tuio.tcp.OSCEvent;

	public class UDPConnector implements IOSCConnector
	{
		private var connection:OSCSocket;
		private var listeners:Array;
		
		public function UDPConnector(host:String = "127.0.0.1", port:int = 3333)
		{
			this.listeners = new Array();
			
			this.connection = new OSCSocket(host, port);
			this.connection.addEventListener(OSCEvent.OSC_DATA,receiveOscData);
		}
		
		public function receiveOscData(e:OSCEvent):void {
			var packet:ByteArray = new ByteArray();
			packet.writeBytes(e.data);
			packet.position = 0;
			
			if (packet != null) {
				if (this.listeners.length > 0) {
					//call receive listeners and push the received messages
					for each(var l:IOSCConnectorListener in this.listeners) {
						if (OSCBundle.isBundle(packet)) {
							l.acceptOSCPacket(new OSCBundle(packet));
						} else if (OSCMessage.isMessage(packet)) {
							l.acceptOSCPacket(new OSCMessage(packet));
						} else {
							//this.debug("\nreceived: invalid osc packet.");
						}
					}
				}
			}
		}
		public function addListener(listener:IOSCConnectorListener):void
		{
			if (this.listeners.indexOf(listener) > -1) return;
			
			this.listeners.push(listener);
		}
		
		public function removeListener(listener:IOSCConnectorListener):void
		{
			var tmp:Array = this.listeners.concat();
			var newList:Array = new Array();
			
			var item:Object = tmp.pop();
			while (item != null) {
				if (item != listener) newList.push(item);
			}
			
			this.listeners = newList;
		}
		
		public function sendOSCPacket(oscPacket:OSCPacket):void
		{
			//not implemented
		}
		
	}
}