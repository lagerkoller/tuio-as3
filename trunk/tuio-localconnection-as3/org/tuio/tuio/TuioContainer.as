package org.tuio.tuio {

	public class TuioContainer {
		
		private var _sessionID:uint;
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _X:Number;
		private var _Y:Number;
		private var _Z:Number;
		private var _m:Number;
		
		public function TuioContainer(sID:Number, x:Number, y:Number, z:Number, X:Number, Y:Number, Z:Number, m:Number) {
			this._sessionID = sID;
			this._x = x;
			this._y = y;
			this._z = z;
			this._X = X;
			this._Y = Y;
			this._Z = Z;
			this._m = m;
			
		}
		
		public function update(x:Number, y:Number, z:Number, X:Number, Y:Number, Z:Number, m:Number) {
			this._x = x;
			this._y = y;
			this._z = z;
			this._X = X;
			this._Y = Y;
			this._Z = Z;
			this._m = m;
		}
		
		public function get sessionID():uint {
			return this._sessionID;
		}
		
		public function get x():Number {
			return this._x;
		}
		
		public function get y():Number {
			return this._y;
		}
		
		public function get z():Number {
			return this._z;
		}
		
		public function get X():Number {
			return this._X;
		}
		
		public function get Y():Number {
			return this._Y;
		}
		
		public function get Z():Number {
			return this._Z;
		}
		
		public function get m():Number {
			return this._m;
		}
	}
	
}