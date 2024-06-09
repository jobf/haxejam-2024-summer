package lib.pure;

@:publicFields
@:structInit
class Node<T>
{
	var item: T;
	var branch_index: Int = 0;
	var branch: Array<Node<T>> = null;
}

@:publicFields
@:structInit
class NodeVisitor<T>
{
	var visit: (node: Node<T>, depth: Int) -> Void;
	var depth_limit: Int = 999;

	function recurse(node: Node<T>, depth: Int = 0)
	{
		visit(node, depth);

		if (depth < depth_limit)
		{
			if (node.branch != null)
			{
				depth++;
				for (joint in node.branch)
				{
					recurse(joint, depth);
				}
			}
		}
	}
}
