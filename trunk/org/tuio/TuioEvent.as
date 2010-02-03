package org.tuio {
	
	import flash.events.Event;
	
	/**
	 * The TuioEvent is an Event equivalent of the ITuioListener callback functions.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioEvent extends Event {
		
		public static const ADD:String = "org.tuio.tuio.TuioEvent.add";
		public static const UPDATE:String = "org.tuio.tuio.TuioEvent.update";
		public static const REMOVE:String = "org.tuio.tuio.TuioEvent.remove";
		
		public static const ADD_OBJECT:String = "org.tuio.tuio.TuioEvent.addObject";
		public static const ADD_CURSOR:String = "org.tuio.tuio.TuioEvent.addCursor";
		public static const ADD_BLOB:String = "org.tuio.tuio.TuioEvent.addBlob";
		
		public static const UPDATE_OBJECT:String = "org.tuio.tuio.TuioEvent.updateObject";
		public static const UPDATE_CURSOR:String = "org.tuio.tuio.TuioEvent.updateCursor";
		public static const UPDATE_BLOB:String = "org.tuio.tuio.TuioEvent.updateBlob";
		
		public static const REMOVE_OBJECT:String = "org.tuio.tuio.TuioEvent.removeObject";
		public static const REMOVE_CURSOR:String = "org.tuio.tuio.TuioEvent.removeCursor";
		public static const REMOVE_BLOB:String = "org.tuio.tuio.TuioEvent.removeBlob";
		
		private var _tuioContainer:TuioContainer;
		
		public function TuioEvent(type:String, tuioContainer:TuioContainer) {
			super(type, false, false);
			this._tuioContainer = tuioContainer;
		}
		
		public function get tuioContainer():TuioContainer {
			return this._tuioContainer;
		}
		
	}
	
}