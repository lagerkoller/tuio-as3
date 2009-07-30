package org.tuio.tuio {
	
    interface ITuioListener {
		
		public function addTuioObject(tuioObject:TuioObject):void;
		public function updateTuioObject(tuioObject:TuioObject):void;
		public function removeTuioObject(tuioObject:TuioObject):void;

		public function addTuioCursor(tuioCursor:TuioCursor):void;
		public function updateTuioCursor(tuioCursor:TuioCursor):void;
		public function removeTuioCursor(tuioCursor:TuioCursor):void;
		
    }
	
}