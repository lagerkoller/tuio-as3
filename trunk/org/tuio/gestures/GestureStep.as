package org.tuio.gestures {
	
	import flash.utils.getTimer;
	import flash.display.DisplayObject;
	import org.tuio.TuioContainer;
	
	public class GestureStep {
		
		private var _event:String;
		private var _targetAlias:String;
		private var _tuioContainerAlias:String;
		private var _frameIDAlias:String;
		private var _minDelay:uint;
		private var _maxDelay:uint;
		private var _die:Boolean;
		private var _prepareTime:int;
		private var _goto:int;
		
		internal var group:GestureStepGroup;
		
		public function GestureStep(event:String, properties:Object) {
			this._event = event;
			this._targetAlias = (properties.targetAlias)?properties.targetAlias.toString():"*";
			this._tuioContainerAlias = (properties.tuioContainerAlias)?properties.tuioContainerAlias.toString():"*";
			this._frameIDAlias = (properties.frameIDAlias)?properties.frameIDAlias.toString():"*";
			this._minDelay = (properties.minDelay)?(properties.minDelay as uint):0;
			this._maxDelay = (properties.maxDelay)?(properties.maxDelay as uint):0;
			this._die = (properties.die)?(properties.die as Boolean):false;
			this._goto = (properties.goto)?(properties.goto as int):-1;
		}
		
		public function prepare():void {
			if(this._maxDelay > 0) this._prepareTime = getTimer();
		}
		
		public function step(event:String, target:DisplayObject, tuioContainer:TuioContainer):uint {
			var wt:int = getTimer() - this._prepareTime;
			var tc:TuioContainer;
			var dObj:DisplayObject;
			if ((this._minDelay <= wt || this._minDelay == 0) && (this._maxDelay >= wt || this._maxDelay == 0)) {
				if (this._event == event) {
					tc = group.getTuioContainer(this._tuioContainerAlias);
					if (this._tuioContainerAlias == "*" || tc == tuioContainer || (!tc && !group.getTuioContainerAlias(tuioContainer))) {
						dObj = group.getTarget(this._targetAlias);
						if (this._targetAlias == "*" || dObj == target || (!dObj && !group.getTargetAlias(target))) {
							if (!tc) group.addTuioContainer(this._tuioContainerAlias, tuioContainer);
							if (!dObj) group.addTarget(this._targetAlias, target);
							this._prepareTime = 0;
							return Gesture.SATURATED;
						} else {
							return Gesture.ALIVE;
						}
					} else {
						return Gesture.ALIVE;
					}
				} else {
					return Gesture.ALIVE;
				}
			} else if (this._minDelay != 0 && this._minDelay >= wt) {
				return Gesture.ALIVE;
			} else {
				this._prepareTime = 0;
				return Gesture.DEAD;
			}
		}
		
		public function copy():GestureStep {
			return new GestureStep(this._event, { 	
				targetAlias:this._targetAlias,
				tuioContainerAlias:this._tuioContainerAlias,
				frameIDAlias:this._frameIDAlias,
				minDelay:this._minDelay,
				maxDelay:this._maxDelay,
				die:this._die 
			});
		}
		
		public function get dies():Boolean {
			return this._die;
		}
		
		public function get event():String {
			return this._event;
		}
		
		public function get goto():int {
			return this._goto;
		}
	}
	
}