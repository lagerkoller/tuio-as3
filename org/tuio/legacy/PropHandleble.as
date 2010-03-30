package org.tuio.legacy{
	 /**
	 * Legacy PropHandleble from fiducialtuioas3 (http://code.google.com/p/fiducialtuioas3/).
	 * 
	 * For a newer version of a fiducial callback implementation see: 
	 * @see org.tuio.fiducial.TuioFiducialDispatcher
	 * @see org.tuio.fiducial.ITuioFiducialReceiver
	 * 
	 * @author Frederic Friess
	 * 
	 */
	public interface PropHandleble{
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