package org.tuio.interactionClients
{
	import org.tuio.ITuioListener;
	import org.tuio.TuioBlob;
	import org.tuio.TuioCursor;
	import org.tuio.TuioObject;

	public class AbstractInteractionClient
	{
		protected var _tuioCursors:Array;
		protected var _tuioObjects:Array;
		protected var _tuioBlobs:Array;
		
		protected var listeners:Array;
		
		public function AbstractInteractionClient(self:AbstractInteractionClient){
			if(self != this){
				throw new Error("Do not initialize this abstract class directly. Instantiate from inheriting class instead.");
			}
			this.listeners = new Array();
			
			this._tuioCursors = new Array();
			this._tuioObjects = new Array();
			this._tuioBlobs = new Array();
		}
		
		/**
		 * Adds a listener to the callback stack. The callback functions of the listener will be called on incoming TUIOEvents.
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
		 * @return A copy of the list of currently active tuioCursors
		 */
		public function get tuioCursors():Array {
			return this._tuioCursors;
		}
		
		/**
		 * @return A copy of the list of currently active tuioObjects
		 */
		public function get tuioObjects():Array {
			return this._tuioObjects;
		}
		
		/**
		 * @return A copy of the list of currently active tuioBlobs
		 */
		public function get tuioBlobs():Array {
			return this._tuioBlobs;
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
		
		protected function dispatchAddCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchUpdateCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchRemoveCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchAddObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioObject(tuioObject);
			}
		}
		
		protected function dispatchUpdateObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioObject(tuioObject);
			}
		}
		
		protected function dispatchRemoveObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioObject(tuioObject);
			}
		}
		
		protected function dispatchAddBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioBlob(tuioBlob);
			}
		}
		
		protected function dispatchUpdateBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioBlob(tuioBlob);
			}
		}
		
		protected function dispatchRemoveBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioBlob(tuioBlob);
			}
		}
	}
}