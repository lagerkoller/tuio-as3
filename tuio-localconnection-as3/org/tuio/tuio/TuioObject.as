package org.tuio.tuio {
	
	public class TuioObject extends TuioContainer {
		
		private var _id:uint;
		private var _a:Number;
		private var _b:Number;
		private var _c:Number;
		private var _A:Number;
		private var _B:Number;
		private var _C:Number;
		private var _r:Number;
		
		public function TuioObject(type:String, sID:Number, i:Number, x:Number, y:Number, z:Number, a:Number, b:Number, c:Number, X:Number, Y:Number, Z:Number, A:Number, B:Number, C:Number, m:Number, r:Number):void {
			super(type, sID, x, y, z, X, Y, Z, m);
			
			this._id = i;
			this._a = a;
			this._b = b;
			this._c = c;
			this._A = A;
			this._B = B;
			this._C = C;
			this._r = r;
		}
		
		public function update(x:Number, y:Number, z:Number, a:Number, b:Number, c:Number, X:Number, Y:Number, Z:Number, A:Number, B:Number, C:Number, m:Number, r:Number):void {
			this._x = x;
			this._y = y;
			this._z = z;
			this._X = X;
			this._Y = Y;
			this._Z = Z;
			this._m = m;
			
			this._a = a;
			this._b = b;
			this._c = c;
			this._A = A;
			this._B = B;
			this._C = C;
			this._r = r;
		}
		
		public function get classID():uint {
			return this._id;
		}
		
		public function get a():uint {
			return this._a;
		}
		
		public function get b():uint {
			return this._b;
		}

		public function get c():uint {
			return this._c;
		}
		
		public function get A():uint {
			return this._A;
		}
		
		public function get B():uint {
			return this._B;
		}

		public function get C():uint {
			return this._C;
		}
		
		public function get r():uint {
			return this.r;
		}
	}
	
}