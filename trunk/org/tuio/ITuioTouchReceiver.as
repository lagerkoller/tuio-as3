package org.tuio
{
	import org.tuio.TuioTouchEvent;

	public interface ITuioTouchReceiver
	{
		function updateTouch(event:TuioTouchEvent):void;
		function removeTouch(event:TuioTouchEvent):void;
	}
}