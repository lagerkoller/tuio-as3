package org.tuio.tuio {
	
	import org.tuio.osc.*;
	
	public class TuioManager implements IOSCListener{
		
		public static const CONNECTION_MODE_TCP:uint = 0;
		public static const CONNECTION_MODE_LC:uint = 1;
		
		private var listeners:Array;
		private var oscManager:OSCManager;
		
		private var fseq:int;
		private var src:String;
		
		private var tuioContainer:Array;
		
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
			
			this.tuioContainer = new Array();
			
		}
		
		public function acceptOSCMessage(msg:OSCMessage):void {
			
			if (msg.arguments[0] == "fseq") this.fseq = int(parseInt(msg.arguments[1]));
			else if (msg.arguments[0] == "source") this.src = msg.arguments[1];
			else if (msg.arguments[0] == "set"){
				
				var isObj:Boolean = false;
				var isBlb:Boolean = false;
				var isCur:Boolean = false;
				
				var is2D:Boolean = false;
				var is25D:Boolean = false;
				var is3D:Boolean = false;
				
				if (msg.addressPattern.indexOf("/tuio/2D") == 0) {
					is2D = true;
				} else if (msg.addressPattern.indexOf("/tuio/25D") == 0) {
					is25D = true;
				} else if (msg.addressPattern.indexOf("/tuio/3D") == 0) {
					is3D = true;
				} else return;
				
				if (msg.addressPattern.indexOf("cur") > -1) {
					isCur = true;
				} else if (msg.addressPattern.indexOf("obj") > -1) {
					isObj = true;
				} else if (msg.addressPattern.indexOf("blb") > -1) {
					isBlb = true;
				} else return;
				
				var s:Number = 0;
				var i:Number = 0;
				var x:Number = 0, y:Number = 0, z:Number = 0;
				var a:Number = 0, b:Number = 0, c:Number = 0;
				var X:Number = 0, Y:Number = 0, Z:Number = 0;
				var A:Number = 0, B:Number = 0, C:Number = 0;
				var w:Number = 0, h:Number = 0, d:Number = 0;
				var f:Number = 0;
				var v:Number = 0;
				var m:Number = 0, r:Number = 0;
				
				var index:uint = 2;
				
				s = Number(msg.arguments[1]);
				
				if (isObj) {
					i = Number(msg.arguments[index++]);
				}
				
				x = Number(msg.arguments[index++]);
				y = Number(msg.arguments[index++]);
				
				if (!is2D) {
					z = Number(msg.arguments[index++]);
				}
				
				if (!isCur) {
					a = Number(msg.arguments[index++]);
					if (is3D) {
						b = Number(msg.arguments[index++]);
						c = Number(msg.arguments[index++]);
					}
				}
				
				if (isBlb) {
					w = Number(msg.arguments[index++]);
					h = Number(msg.arguments[index++]);
					if (!is3D) {
						f = Number(msg.arguments[index++]);
					} else {
						d = Number(msg.arguments[index++]);
						v = Number(msg.arguments[index++]);
					}
				}
				
				X = Number(msg.arguments[index++]);
				Y = Number(msg.arguments[index++]);
				
				if (!is2D) {
					Z = Number(msg.arguments[index++]);
				}
				
				if (!isCur) {
					A = Number(msg.arguments[index++]);
					if (msg.addressPattern.indexOf("/tuio/3D") == 0) {
						B = Number(msg.arguments[index++]);
						C = Number(msg.arguments[index++]);
					}
				}
				
				m = Number(msg.arguments[index++]);
				
				if (!isCur) {
					r = Number(msg.arguments[index++]);
				}
				
				//generate object
				
				var type:String = msg.addressPattern.substring(6, msg.addressPattern.length);
				
				var tuioContainer:TuioContainer;
				
				if (isCur) {
					tuioContainer = new TuioCursor(type, s, x, y, z, X, Y, Z, m);
				} else if (isObj) {
					tuioContainer = new TuioObject(type, s, i, x, y, z, a, b, c, X, Y, Z, A, B, C, m, r);
				} else if (isBlb) {
					tuioContainer = new TuioBlob(type, s, x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r);
				} else return;
				
				//resolve if add or update
				
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
		
		public function get currentFseq():int {
			return this.fseq;
		}
		
		public function get currentSource():String {
			return this.src;
		}

	}
	
}