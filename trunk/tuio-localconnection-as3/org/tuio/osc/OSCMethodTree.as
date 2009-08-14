package org.tuio.osc {
	
	public class OSCMethodTree {
		
		private var root:OSCMethodNode;
		
		public function OSCMethodTree() {
			this.root = new OSCMethodNode("");
		}
		
		public function addMethod(address:String, method:IOSCListener):void {
			var parts:Array = address.split("/");
			var part:String;
			var currentNode:OSCMethodNode = root;
			var newNode:OSCMethodNode;
			while (parts.length > 0) {
				part = parts.pop();
				newNode = currentNode.getChild(part);
				if (newNode == null) {
					newNode = new OSCMethodNode(part);
					currentNode.addChild(newNode);
				}
				currentNode = newNode;
			}
			currentNode.method = method;
		}
		
		public function removeMethod(address:String) {
			var parts:Array = address.split("/");
			var part:String;
			var currentNode:OSCMethodNode = root;
			var newNode:OSCMethodNode;
			while (parts.length > 0) {
				part = parts.pop();
				newNode = currentNode.getChild(part);
				if (newNode == null) {
					break;
				}
				currentNode = newNode;
			}
			currentNode.parent.removeChild(currentNode);
		}
		
		public function getMethods(pattern:String):Array {
			return root.getMatchingChildren(pattern.substr(1, pattern.length));
		}
		
	}
	
}