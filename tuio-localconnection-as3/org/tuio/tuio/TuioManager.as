package org.tuio.tuio {
	
	import org.tuio.osc.*;
	
	public class TuioManager implements IOSCListener{
		
		public static const CONNECTION_MODE_TCP:uint = 0;
		public static const CONNECTION_MODE_LC:uint = 1;
		
		private var listeners:Array;
		private var oscManager:OSCManager;
		
		public function TuioManager(connectionMode:uint) {
			
			var connector:IOSCConnector;
			
			if (connectionMode == CONNECTION_MODE_TCP) {
				
			} else if (connectionMode == CONNECTION_MODE_LC) {
				connector = new LCConnector("_TuioOscDataStream");
			} else {
				//maybe throw exception
			}
			
			if (connector != null) {
				this.oscManager = new OSCManager();
				//set TuioManager or extra handler classes as listener
			}
			
			this.listeners = new Array();
			
		}
		
		public function acceptOSCMessage(msg:OSCMessage):void {
			
			var s:uint;
			var i:uint;
			var x:Number, y:Number, z:Number;
			var a:Number, b:Number, c:Number;
			var X:Number, Y:Number, Z:Number;
			var A:Number, B:Number, C:Number;
			var w:Number, h:Number, d:Number;
			var df:Number;
			var m:Number, r:Number;
			
			if (msg.addressPattern == "/tuio/2Dcur") {
				
			} else if (msg.addressPattern == "/tuio/25Dcur") {
				
			} else if (msg.addressPattern == "/tuio/3Dcur") {
				
			} else if (msg.addressPattern == "/tuio/2Dobj") {
				
			} else if (msg.addressPattern == "/tuio/25Dobj") {
				
			} else if (msg.addressPattern == "/tuio/3Dobj") {
				
			} else if (msg.addressPattern == "/tuio/2Dblb") {
				
			} else if (msg.addressPattern == "/tuio/25Dblb") {
				
			} else if (msg.addressPattern == "/tuio/3Dblb") {
				
			}
			
		}
		
		public function addListener(listener:ITuioListener) {
			if (this.listeners.indexOf(listener) > -1) return;
			this.listeners.push(listener);
		}
		
		
		public function removeListener(listener:ITuioListener):void {
			var temp:Array = new Array();
			for each(var l:ITuioListener in this.listeners) {
				if (l != listener) temp.push(l);
			}
			this.listeners = temp.concat();
		}

	}
	
}