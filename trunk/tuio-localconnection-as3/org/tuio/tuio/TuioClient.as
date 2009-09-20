package org.tuio.tuio {
	
	import org.tuio.osc.*;
	
	/**
	 * A Class for receiving multitouch tracking data via the TUIO protocol.
	 * 
	 * @author Immanuel Bauer
	 * 
	 */
	public class TuioClient implements IOSCListener{
		
		public static const CONNECTION_MODE_TCP:uint = 0;
		public static const CONNECTION_MODE_LC:uint = 1;
		
		private var listeners:Array;
		private var oscManager:OSCManager;
		
		private var fseq:int;
		private var src:String;
		
		private var _tuioCursors:Array;
		private var _tuioObjects:Array;
		private var _tuioBlobs:Array;
		
		/**
		 * @param	connectionMode The connection mode used to receive the TUIO tracking data. Either TuioClient.CONNECTION_MODE_TCP or CONNECTION_MODE_LC. Default is TuioClient CONNECTION_MODE_LC.
		 */
		public function TuioClient(connectionMode:uint = TuioClient.CONNECTION_MODE_LC) {
			
			this.listeners = new Array();
			
			this._tuioCursors = new Array();
			this._tuioObjects = new Array();
			this._tuioBlobs = new Array();
			
			var connector:IOSCConnector;
			
			if (connectionMode == CONNECTION_MODE_TCP) {
				connector = new TCPConnector();
			} else if (connectionMode == CONNECTION_MODE_LC) {
				connector = new LCConnector();
			} else {
				throw new ArgumentError("The specified connection mode isn't valid.");
			}
			
			if (connector != null) {
				this.oscManager = new OSCManager(connector);
				this.oscManager.addMsgListener(this);
			}
			
		}
		
		/**
		 * Callback function for receiving TUIO tracking data in OSCMessages.
		 * 
		 * @param	msg The OSCMessage containing a single TUIOEvent.
		 */
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
					tuioContainerList = this._tuioCursors;
				} else if (isObj) {
					tuioContainerList = this._tuioObjects;
				} else if (isBlb) {
					tuioContainerList = this._tuioBlobs;
				} else return;
				
				//resolve if add or update
				for each(var tc:TuioContainer in tuioContainerList) {
					if (tc.sessionID == s) {
						tuioContainer = tc;
						break;
					}
				}
				
				if(tuioContainer == null){
					if (isCur) {
						tuioContainer = new TuioCursor(type, s, x, y, z, X, Y, Z, m);
						this._tuioCursors.push(tuioContainer);
						dispatchAddCursor(tuioContainer as TuioCursor);
					} else if (isObj) {
						tuioContainer = new TuioObject(type, s, i, x, y, z, a, b, c, X, Y, Z, A, B, C, m, r);
						this._tuioObjects.push(tuioContainer);
						dispatchAddObject(tuioContainer as TuioObject);
					} else if (isBlb) {
						tuioContainer = new TuioBlob(type, s, x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r);
						this._tuioBlobs.push(tuioContainer);
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
					
					for each(var tcur:TuioCursor in this._tuioCursors) {
						tcur.isAlive = false;
					}
					
					for (var k:uint = 1; k < msg.arguments.length; k++){
						for each(tcur in this._tuioCursors) {
							if (tcur.sessionID == msg.arguments[k]) {
								tcur.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioCursors.concat();
					this._tuioCursors = new Array();
					
					for each(tcur in tuioContainerList) {
						if (tcur.isAlive) this._tuioCursors.push(tcur);
						else {
							dispatchRemoveCursor(tcur);
						}
					}
					
				} else if (msg.addressPattern.indexOf("obj") > -1) {
					
					for each(var to:TuioObject in this._tuioObjects) {
						to.isAlive = false;
					}
					
					for (var t:uint = 1; t < msg.arguments.length; t++){
						for each(to in this._tuioObjects) {
							if (to.sessionID == msg.arguments[t]) {
								to.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioObjects.concat();
					this._tuioObjects = new Array();
					
					for each(to in tuioContainerList) {
						if (to.isAlive) this._tuioObjects.push(to);
						else {
							dispatchRemoveObject(to);
						}
					}
					
				} else if (msg.addressPattern.indexOf("blb") > -1) {
					
					for each(var tb:TuioBlob in this._tuioBlobs) {
						tb.isAlive = false;
					}
					
					for (var u:uint = 1; u < msg.arguments.length; u++){
						for each(tb in this._tuioBlobs) {
							if (tb.sessionID == msg.arguments[u]) {
								tb.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioBlobs.concat();
					this._tuioBlobs = new Array();
					
					for each(tb in tuioContainerList) {
						if (tb.isAlive) this._tuioBlobs.push(tb);
						else {
							dispatchRemoveBlob(tb);
						}
					}
					
				} else return;
				
			}
		}
		
		/**
		 * Adds a listener to the callback stack . The callback functions of the listener will be called on incoming TUIOEvents.
		 * 
		 * @param	listener Object of a class that implements the callback functions defined in the ITuioListener interface.
		 */
		public function addListener(listener:ITuioListener):void {
			if (this.listeners.indexOf(listener) > -1) return;
			this.listeners.push(listener);
		}
		
		/**
		 * Removes the given listener from the callback stack.
		 * 
		 * @param	listener
		 */
		public function removeListener(listener:ITuioListener):void {
			var temp:Array = new Array();
			for each(var l:ITuioListener in this.listeners) {
				if (l != listener) temp.push(l);
			}
			this.listeners = temp.concat();
		}
		
		/**
		 * @return The last received fseq value by the tracker.
		 */
		public function get currentFseq():int {
			return this.fseq;
		}
		
		/**
		 * @return The last received source specification by the tracker.
		 */
		public function get currentSource():String {
			return this.src;
		}
		
		/**
		 * @return A copy of the list of currently active tuioCursors
		 */
		public function get tuioCursors():Array {
			return this._tuioCursors.concat();
		}
		
		/**
		 * @return A copy of the list of currently active tuioObjects
		 */
		public function get tuioObjects():Array {
			return this._tuioObjects.concat();
		}
		
		/**
		 * @return A copy of the list of currently active tuioBlobs
		 */
		public function get tuioBlobs():Array {
			return this._tuioBlobs.concat();
		}
		
		/**
		 * @param	sessionID The sessionID of the designated tuioCursor
		 * @return The tuioCursor matching the given sessionID. Returns null if the tuioCursor doesn't exists
		 */
		public function getTuioCursor(sessionID:Number):TuioCursor {
			var out:TuioCursor = null;
			for each(var tc:TuioCursor in this._tuioCursors) {
				if (tc.sessionID == sessionID) {
					out = tc;
					break;
				}
			}
			return out;
		}
		
		/**
		 * @param	sessionID The sessionID of the designated tuioObject
		 * @return The tuioObject matching the given sessionID. Returns null if the tuioObject doesn't exists
		 */
		public function getTuioObject(sessionID:Number):TuioObject {
			var out:TuioObject = null;
			for each(var to:TuioObject in this._tuioObjects) {
				if (to.sessionID == sessionID) {
					out = to;
					break;
				}
			}
			return out;
		}
		
		/**
		 * @param	sessionID The sessionID of the designated tuioBlob
		 * @return The tuioBlob matching the given sessionID. Returns null if the tuioBlob doesn't exists
		 */
		public function getTuioBlob(sessionID:Number):TuioBlob {
			var out:TuioBlob = null;
			for each(var tb:TuioBlob in this._tuioBlobs) {
				if (tb.sessionID == sessionID) {
					out = tb;
					break;
				}
			}
			return out;
		}
		
		/**
		 * Helper functions for dispatching TUIOEvents to the ITuioListeners.
		 */
		
		private function dispatchAddCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchUpdateCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchRemoveCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioCursor(tuioCursor);
			}
		}
		
		private function dispatchAddObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioObject(tuioObject);
			}
		}
		
		private function dispatchUpdateObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioObject(tuioObject);
			}
		}
		
		private function dispatchRemoveObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioObject(tuioObject);
			}
		}
		
		private function dispatchAddBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioBlob(tuioBlob);
			}
		}
		
		private function dispatchUpdateBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioBlob(tuioBlob);
			}
		}
		
		private function dispatchRemoveBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioBlob(tuioBlob);
			}
		}

	}
	
}