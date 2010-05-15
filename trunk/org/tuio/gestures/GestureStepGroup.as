package org.tuio.gestures {
	
	import flash.utils.getTimer;
	import flash.display.DisplayObject;
	import org.tuio.TuioContainer;
	
	public class GestureStepGroup {
		
		private var steps:Array;
		private var stepPosition:uint;
		private var targetAliasMap:Object;
		private var tuioContainerAliasMap:Object;
		private var frameIDAliasMap:Object;
		private var _gesture:Gesture;
		private var _active:Boolean;
		
		public function GestureStepGroup() {
			this.steps = new Array();
			this.targetAliasMap = {};
			this.tuioContainerAliasMap = {};
			this.frameIDAliasMap = {};
			this.stepPosition = 0;
			this._active = true;
		}

		public function get firstStep():GestureStep {
			var step:GestureStep;
			for (var i:int = 0; i < steps.length; i++ ) {
				step = this.steps[i] as GestureStep;
				if(!step.dies) return step.copy();
			}
			return null;
		}
		
		public function get gesture():Gesture {
			return this._gesture;
		}
		
		public function set gesture(g:Gesture):void {
			this._gesture = g;
		}
		
		internal function addStep(s:GestureStep):void {
			s.group = this;
			this.steps.push(s);
		}
		
		internal function getTarget(alias:String):DisplayObject {
			return this.targetAliasMap[alias] as DisplayObject;
		}
		
		internal function addTarget(alias:String, target:DisplayObject):void {
			this.targetAliasMap[alias] = target;
		}
		
		internal function getTuioContainer(alias:String):TuioContainer {
			return this.tuioContainerAliasMap[alias] as TuioContainer;
		}
		
		internal function addTuioContainer(alias:String, tuioContainer:TuioContainer):void {
			this.tuioContainerAliasMap[alias] = tuioContainer;
		}
		
		internal function getFrameID(alias:String):uint {
			if (alias.charAt(0) == "!") alias = alias.substr(1);
			return uint(this.frameIDAliasMap[alias]);
		}
		
		internal function addFrameID(alias:String, frameID:uint):void {
			if (alias.charAt(0) == "!") alias = alias.substr(1);
			this.frameIDAliasMap[alias] = frameID;
		}
		
		internal function getTargetAlias(target:DisplayObject):String {
			return getKey(targetAliasMap, target);
		}
		
		internal function getTuioContainerAlias(tuioContainer:TuioContainer):String {
			return getKey(tuioContainerAliasMap, tuioContainer);
		}
		
		internal function getFrameIDAlias(frameID:int):String {
			return getKey(frameIDAliasMap, frameID);
		}
		
		private function getKey(a:Object, value:Object):String {
			for(var k:String in a) {
				if (a[k] == value) return k;
			} 
			return null;
		}
		
		public function step(event:String, target:DisplayObject, tuioContainer:TuioContainer):uint {

			var step:GestureStep = this.steps[stepPosition] as GestureStep;
			var result:uint = step.step(event, target, tuioContainer);
			var dieOffset:int = 0;
			var goto:int;
			
			while (true) {
				if (result == Gesture.SATURATED && !step.dies) {
					stepPosition++;
					this.gesture.dispatchEvent(new GestureStepEvent(GestureStepEvent.SATURATED, stepPosition, this));
					if (stepPosition < steps.length) {
						prepareNext();
						return Gesture.PROGRESS;
					} else {
						goto = step.goto;
						if (goto > 0 && goto <= steps.length) {
							stepPosition = goto - 1;
							prepareNext();
						} else {
							this._active = false;
						}
						return Gesture.SATURATED;
					}
				} else if (result == Gesture.ALIVE || (result == Gesture.DEAD && step.dies)) {
					if (step.dies) {
						stepPosition++;
						dieOffset++;
						step = this.steps[stepPosition] as GestureStep;
						result = step.step(event, target, tuioContainer);
					} else {
						stepPosition -= dieOffset;
						return Gesture.ALIVE;
					}
				} else {
					this.gesture.dispatchEvent(new GestureStepEvent(GestureStepEvent.DEAD, stepPosition+1, this));
					this._active = false;
					return Gesture.DEAD;
				}
			}
			
			return Gesture.ALIVE;
		}
		
		private function prepareNext():void {
			var o:int = 0;
			var nextStep:GestureStep = this.steps[stepPosition];
			var stepLength:int = this.steps.length-1;
			nextStep.prepare();
			while(nextStep.dies && (stepPosition + o) < stepLength ) {
				o++;
				nextStep = this.steps[stepPosition + o];
				nextStep.prepare();
			}
		}
		
		public function copy():GestureStepGroup {
			var out:GestureStepGroup = new GestureStepGroup();
			out.gesture = this.gesture;
			var al:int = steps.length;
			for (var c:int = 0; c < al; c++ ) {
				out.addStep((steps[c] as GestureStep).copy());
			}
			return out;
		}
	
		public function get active():Boolean {
			return this._active;
		}
		
	}
	
}