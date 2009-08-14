package org.tuio.osc {
	
	public class OSCMethodNode {
		
		private var children:Array;
		private var name:String;
		public var method:IOSCListener;
		public var parent:OSCMethodNode;
		
		public function OSCMethodNode(name:String, method:IOSCListener = null, parent:OSCMethodNode = null){
			this.name = name;
			this.method = method;
			this.parent = parent;
		}
		
		public function addChild(child:OSCMethodNode):void {
			this.children[child.name] = child;
		}
		
		public function getChild(name:String):OSCMethodNode {
			return this.children[name];
		}
		
		public function getMatchingChildren(pattern:String):Array {
			var out:Array = new Array();
			
			var firstSeperator:int = pattern.indexOf("/");
			var part:String = pattern.substring(0, firstSeperator);
			var rest:String = pattern.substring(firstSeperator + 1, pattern.length); 
			var done:Boolean = (pattern.indexOf("/")==-1);
			
			for each(var child:OSCMethodNode in this.children) {
				
				if (child.matchName(part)) {
					if (done) {
						if(child.method != null) out.push(child.method);
					} else {
						out = out.concat(child.getMatchingChildren(rest));
					}
				}
				
			}
			
			return out;
		}
		
		public function removeChild(child:OSCMethodNode) {
			if (child.hasChildren) child.method = null;
			else this.children[child.name] = null;
		}
		
		public function matchName(pattern:String):Boolean {
			
			if (pattern == this.name) return true;
			
			if (pattern == "*") return true;
			
			return false;
			
		}
		
		public function get hasChildren() {
			
			return (children.length > 0);
			
		}
		
	}
	
}