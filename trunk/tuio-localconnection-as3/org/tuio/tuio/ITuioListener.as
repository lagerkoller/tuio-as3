package org.tuio.tuio {
	
    public interface ITuioListener {
		
		function addTuioObject(tuioObject:TuioObject):void;
		function updateTuioObject(tuioObject:TuioObject):void;
		function removeTuioObject(tuioObject:TuioObject):void;

		function addTuioCursor(tuioCursor:TuioCursor):void;
		function updateTuioCursor(tuioCursor:TuioCursor):void;
		function removeTuioCursor(tuioCursor:TuioCursor):void;
		
		function addTuioBlob(tuioCursor:TuioBlob):void;
		function updateTuioBlob(tuioCursor:TuioBlob):void;
		function removeTuioBlob(tuioCursor:TuioBlob):void;
		
    }
	
}