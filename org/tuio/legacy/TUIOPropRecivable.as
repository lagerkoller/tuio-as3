package org.tuio.legacy{
	import flash.display.Sprite;
	
	/**
	 * Legacy TUIOPropRecivable interface from fiducialtuioas3 (http://code.google.com/p/fiducialtuioas3/).
	 * 
	 * For a newer version of a fiducial callback implementation see <code>org.tuio.fiducial.TuioFiducialDispatcher</code> and 
	 * <code>org.tuio.fiducial.ITuioFiducialReceiver</code>.
	 * 
	 * @author Frederic Friess
	 * 
	 */
	public interface TUIOPropRecivable
	{
		function onAdd(evt:PropEvent);
		function onRemove(evt:PropEvent);
		
		function onMove(evt:PropEvent);
		function onRotate(evt:PropEvent);
		function onMoveVelocety(evt:PropEvent);
		function onRotateVelocety(evt:PropEvent);
		function onMoveAccel(evt:PropEvent);
		function onRotateAccel(evt:PropEvent);
	}
	
	
}