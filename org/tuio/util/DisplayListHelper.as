package org.tuio.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;

	import org.tuio.debug.ITuioDebugBlob;
	import org.tuio.debug.ITuioDebugCursor;
	import org.tuio.debug.ITuioDebugObject;
	import org.tuio.debug.ITuioDebugTextSprite;

	/**
	 * This class provides static functions for display list traversals and lookups which are used internally.
	 */
	public class DisplayListHelper
	{

		/**
		 * Finds the most top DisplayObject under a given point which is eanbled for user interaction.
		 */
		public static function getTopDisplayObjectUnderPoint(point:Point, stage:Stage):DisplayObject {
			var targets:Array =  stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;

			while(targets.length > 0) {
				item = targets.pop() as DisplayObject;
				//ignore debug cursor/object/blob and send object under debug cursor/object/blob
				if((item is ITuioDebugCursor || item is ITuioDebugBlob || item is ITuioDebugObject || item is ITuioDebugTextSprite) && targets.length > 1){
					continue;
				}
				if (item.parent != null && !(item is InteractiveObject)) item = item.parent;
				if (item is InteractiveObject) {
					if ((item as InteractiveObject).mouseEnabled) return item;
				}
			}
			item = stage;

			return item;
		}

		public static function bubbleListCheck(obj:DisplayObject):Boolean {
			if (obj.parent != null) {
				return bubbleListCheck(obj.parent);
			} else {
				return false;
			}
		}

		/**
		 * looks for a an object of a given type (className) below a given point. If the instance of an object should be ignored (mainly because it is also of the
		 * type className), it can also be passed as an argument.
		 * @param point the point under which objects should be determined.
		 * @param className type of which the searched object has to be.
		 * @param stage
		 * @param ignoreObject instance that should be ignored even if it is of the type className
		 * @return the first object of the type className under point (if it is not ignoreObject). If no object is found, stage will be returned.
		 *
		 */
		public static function getTopObjectUnderPoint(point:Point, className:Class, stage:Stage, ignoreObject:DisplayObject=null):DisplayObject {
			var item:DisplayObject;
			if(stage != null){
				var targets:Array =  stage.getObjectsUnderPoint(point);

				while(targets.length > 0) {
					item = targets.pop() as DisplayObject;
					item = testItemForClassName(item, className, stage, ignoreObject);
					if(item != null){
						break;
					}
				}
				if(item == null){
					item = stage;
				}
			}
			return item;
		}

		/**
		 * checks whether item is of type className. If it is (and if it is not ignoreObject) the item will be returned. If item is not of type className
		 * its parent will be checked (recursively).
		 * @param item
		 * @param className
		 * @param stage
		 * @param ignoreObject
		 * @return
		 *
		 */
		private static function testItemForClassName(item:DisplayObject, className:Class, stage:Stage, ignoreObject:DisplayObject):DisplayObject{
			var returnObject:DisplayObject = null;
			if(item is className){
				if(item != ignoreObject){
					returnObject = item;
				}
			}else if(item.parent != null){
				returnObject = testItemForClassName(item.parent, className, stage, ignoreObject);
			}

			return returnObject;
		}

		public static function getTopObjectUnderPointBelowDisplayObject(point:Point, stage:Stage, displayObjectAbove:DisplayObjectContainer):DisplayObject {
			var item:DisplayObject;
			if(stage != null){
				var targets:Array =  stage.getObjectsUnderPoint(point);

				var displayObjectAboveFound:Boolean = false;
				var displayObjectBelowFound:Boolean = false;
				while(targets.length > 0) {
					item = targets.pop() as DisplayObject;
					if(!displayObjectAboveFound){
						displayObjectAboveFound = testItemForDisplayObject(item, stage, displayObjectAbove);
					}else{
						if(!displayObjectAbove.contains(item)){
							displayObjectBelowFound = true
							break;
						}
					}
				}

				if(!displayObjectBelowFound){
					item = stage;
				}
			}
			return item;
		}

		private static function testItemForDisplayObject(item:DisplayObject, stage:Stage, displayObjectAbove:DisplayObject):Boolean{
			var isDisplayObject:Boolean = false;
			if(item == displayObjectAbove){
				isDisplayObject = true;
			}else if(item.parent != null){
				isDisplayObject = testItemForDisplayObject(item.parent, stage, displayObjectAbove);
			}

			return isDisplayObject;
		}
	}
}