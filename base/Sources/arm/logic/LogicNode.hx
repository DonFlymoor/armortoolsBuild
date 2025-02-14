package arm.logic;

class LogicNode {
	var tree: LogicTree;
	var inputs: Array<LogicNodeInput> = [];
	var outputs: Array<Array<LogicNode>> = [];

	public function new(tree: LogicTree) {
		this.tree = tree;
	}

	public function addInput(node: LogicNode, from: Int) {
		inputs.push(new LogicNodeInput(node, from));
	}

	public function addOutputs(nodes: Array<LogicNode>) {
		outputs.push(nodes);
	}

	public function get(from: Int, done: Dynamic->Void) {
		done(null);
	}

	public function getAsImage(from: Int, done: kha.Image->Void) {
		done(null);
	}

	public function getCachedImage(): kha.Image {
		return null;
	}

	public function set(value: Dynamic) {}
}

class LogicNodeInput {
	var node: LogicNode;
	var from: Int; // Socket index

	public function new(node: LogicNode, from: Int) {
		this.node = node;
		this.from = from;
	}

	public function get(done: Dynamic->Void) {
		node.get(from, done);
	}

	public function getAsImage(done: kha.Image->Void) {
		node.getAsImage(from, done);
	}

	public function set(value: Dynamic) {
		node.set(value);
	}
}

class LogicTree extends iron.Trait {
	public function new() {
		super();
	}
}
