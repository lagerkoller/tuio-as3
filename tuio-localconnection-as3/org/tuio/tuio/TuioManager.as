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
				
			} else {
				//maybe throw exception
			}
			
			if (connector != null) {
				this.oscManager = new OSCManager(new LCConnector("_TuioOscDataStream"));
				//set TuioManager or extra handler classes as listener
			}
			
			this.listeners = new Array();
			
		}
		
		public function acceptOSCMessage(msg:OSCMessage):void {
			
			
			
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