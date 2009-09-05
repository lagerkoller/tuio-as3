package org.tuio.tuio {
	
	public class TuioCursor extends TuioContainer {
		
		public function TuioCursor(type:String, sID:Number, x:Number, y:Number, z:Number, X:Number, Y:Number, Z:Number, m:Number ) {
			super(type, sID, x, y, z, X, Y, Z, m);
		}
	
		public function update(x:Number, y:Number, z:Number, X:Number, Y:Number, Z:Number, m:Number):void {
			this._x = x;
			this._y = y;
			this._z = z;
			this._X = X;
			this._Y = Y;
			this._Z = Z;
			this._m = m;
		}
		
	}
	
}