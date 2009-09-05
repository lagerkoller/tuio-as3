package org.tuio.tuio {
	
	import org.tuio.osc.*;
	
	public class TuioManager implements IOSCListener{
		
		public static const CONNECTION_MODE_TCP:uint = 0;
		public static const CONNECTION_MODE_LC:uint = 1;
		
		private var listeners:Array;
		private var oscManager:OSCManager;
		
		private var fseq:int;
		private var src:String;
		
		private var tuioCursors:Array;
		private var tuioObjects:Array;
		private var tuioBlobs:Array;
		
		public function TuioManager(connectionMode:uint) {
			
			this.listeners = new Array();
			
			this.tuioCursors = new Array();
			this.tuioObjects = new Array();
			this.tuioBlobs = new Array();
			
			var connector:IOSCConnector;
			
			if (connectionMode == CONNECTION_MODE_TCP) {
				
			} else if (connectionMode == CONNECTION_MODE_LC) {
				connector = new LCConnector("_TuioOscDataStream");
			} else {
				throw new ArgumentError("The specified connection mode isn't valid.");
			}
			
			if (connector != null) {
				this.oscManager = new OSCManager();
				this.oscManager.addMsgListener(this);
			}
			
		}
		
		public function acceptOSCMessage(msg:OSCMessage):void {
			
			var tuioContainerList:Array;
			
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
					tuioContainerList = this.tuioCursors;
				} else if (isObj) {
					tuioContainerList = this.tuioObjects;
				} else if (isBlb) {
					tuioContainerList = this.tuioBlobs;
				} else return;
				
				//resolve if add or update
				for each(var tc:TuioContainer in tuioContainerList) {
					if (tc.sessionID == tuioContainer.sessionID) {
						tuioContainer = tc;
						break;
					}
				}
				
				if(tuioContainer == null){
					if (isCur) {
						tuioContainer = new TuioCursor(type, s, x, y, z, X, Y, Z, m);
						this.tuioCursors.push(tuioContainer);
						dispatchAddCursor(tuioContainer as TuioCursor);
					} else if (isObj) {
						tuioContainer = new TuioObject(type, s, i, x, y, z, a, b, c, X, Y, Z, A, B, C, m, r);
						this.tuioObjects.push(tuioContainer);
						dispatchAddObject(tuioContainer as TuioObject);
					} else if (isBlb) {
						tuioContainer = new TuioBlob(type, s, x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r);
						this.tuioBlobs.push(tuioContainer);
						dispatchAddBlob(tuioContainer as TuioBlob);
					} else return;
					
				} else {
					if (isCur) {
						(tuioContainer as TuioCursor).update(x, y, z, X, Y, Z, m);
						dispatchUpdateCursor(tuioContainer as TuioCursor);
					} else if (isObj) {
						(tuioContainer as TuioObject).update(x, y, z, a, b, c, X, Y, Z, A, B, C, m, r);
						dispatchUpdateObject(tuioContainer as TuioObject);
					} else if (isBlb) {
						(tuioContainer as TuioBlob).update(x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r);
						dispatchUpdateBlob(tuioContainer as TuioBlob);
					} else return;
				}
				
			} else if (msg.arguments[0] == "alive") {
				
				if (msg.addressPattern.indexOf("cur") > -1) {
					
					for each(var tcur:TuioCursor in this.tuioCursors) {
						tcur.isAlive = false;
					}
					
					for (var k:uint = 1; k < msg.arguments.length; k++){
						for each(tcur in this.tuioCursors) {
							if (tcur.sessionID == msg.arguments[k]) {
								tcur.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this.tuioCursors.concat();
					this.tuioCursors = new Array();
					
					for each(tcur in tuioContainerList) {
						if (tcur.isAlive) this.tuioCursors.push(tcur);
						else {
							dispatchRemoveCursor(tcur);
						}
					}
					
				} else if (msg.addressPattern.indexOf("obj") > -1) {
					
					for each(var to:TuioObject in this.tuioObjects) {
						to.isAlive = false;
					}
					
					for (var t:uint = 1; t < msg.arguments.length; t++){
						for each(to in this.tuioObjects) {
							if (to.sessionID == msg.arguments[t]) {
								to.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this.tuioObjects.concat();
					this.tuioObjects = new Array();
					
					for each(to in tuioContainerList) {
						if (to.isAlive) this.tuioObjects.push(to);
						else {
							dispatchRemoveObject(to);
						}
					}
					
				} else if (msg.addressPattern.indexOf("blb") > -1) {
					
					for each(var tb:TuioBlob in this.tuioBlobs) {
						tb.isAlive = false;
					}
					
					for (var u:uint = 1; u < msg.arguments.length; u++){
						for each(tb in this.tuioBlobs) {
							if (tb.sessionID == msg.arguments[u]) {
								tb.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this.tuioBlobs.concat();
					this.tuioBlobs = new Array();
					
					for each(tb in tuioContainerList) {
						if (tb.isAlive) this.tuioBlobs.push(tb);
						else {
							dispatchRemoveBlob(tb);
						}
					}
					
				} else return;
				
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
		
		private function dispatchAddCursor(tuioCursor:TuioCursor) {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchUpdateCursor(tuioCursor:TuioCursor) {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchRemoveCursor(tuioCursor:TuioCursor) {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchAddObject(tuioObject:TuioObject) {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioObject(tuioObject);
			}
		}
		
		private function dispatchUpdateObject(tuioObject:TuioObject) {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioObject(tuioObject);
			}
		}
		
		private function dispatchRemoveObject(tuioObject:TuioObject) {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioObject(tuioObject);
			}
		}
		
		private function dispatchAddBlob(tuioBlob:TuioBlob) {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioBlob(tuioBlob);
			}
		}
		
		private function dispatchUpdateBlob(tuioBlob:TuioBlob) {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioBlob(tuioBlob);
			}
		}
		
		private function dispatchRemoveBlob(tuioBlob:TuioBlob) {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioBlob(tuioBlob);
			}
		}

	}
	
}