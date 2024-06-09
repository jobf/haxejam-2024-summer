package lib.pure;

import lib.pure.Node;

interface IMenu
{
	function iterate_selection(direction: Int): Void;

	function ascend(): Void;

	function descend(): Void;

	function perform_selected_action(): Void;
}

class Menu implements IMenu
{
	var depth: Int;
	var index: Int;
	var nodes: Array<Node<MenuItem>>;
	var on_navigate: () -> Void;
	var on_action: () -> Void;
	var higher_nodes: Array<Array<Node<MenuItem>>>;
	var higher_indexes: Array<Int>;

	public function new(items: Array<MenuItemConfig>, on_navigate: () -> Void = null, on_action: () -> Void = null)
	{
		depth = 0;
		index = 0;
		nodes = to_nodes(items);
		if (on_navigate == null)
		{
			this.on_navigate = () -> return;
		}
		else
		{
			this.on_navigate = on_navigate;
		}
		if (on_action == null)
		{
			this.on_action = () -> return;
		}
		else
		{
			this.on_action = on_action;
		}
		higher_nodes = [];
		higher_indexes = [];
	}

	function to_nodes(items: Array<MenuItemConfig>): Array<Node<MenuItem>>
	{
		return [
			for (config in items)
			{
				var node: Node<MenuItem> = {
					item: {
						item_type: config.item_type,
						label: config.label,
						action: config.action,
						on_slide: config.on_slide,
						is_valid: config.is_valid,
						description: config.description
					},
				}

				if (config.sub_items != null)
				{
					node.branch = to_nodes(config.sub_items);
				}

				node;
			}
		];
	}

	public function recurse_with(label_creator: NodeVisitor<MenuItem>)
	{
		for (node in nodes)
		{
			label_creator.recurse(node);
		}
	}

	public function perform_selected_action()
	{
		if (nodes[index].item.is_valid())
		{
			nodes[index].item.action();
			on_action();
			if (nodes[index].item.on_actioned != null)
			{
				nodes[index].item.on_actioned(nodes[index].item);
			}
			for (i => node in nodes)
			{
				if (index != i && node.item.on_reset != null)
				{
					node.item.on_reset(node.item);
				}
			}
		}
	}

	public function selected_label(): String
	{
		return nodes[index].item.label;
	}

	public function selected_description(): String
	{
		return nodes[index].item.description;
	}

	public function iterate_selection(direction: Int)
	{
		index = (index + nodes.length + direction) % nodes.length;
		if (nodes[index].item.on_select != null)
		{
			nodes[index].item.on_select(nodes[index].item);
		}
		on_navigate();
	}

	// public function change_selection(index: Int)
	// {
	// 	this.index = index;
	// 	if (nodes[index].item.on_select != null)
	// 	{
	// 		nodes[index].item.on_select(nodes[index].item);
	// 	}
	// }

	public function change_selection(item: MenuItem)
	{
		index = find_node_index(item);
		on_navigate();
	}

	inline function find_node_index(item: MenuItem): Int
	{
		var index = 0;
		for (node in nodes)
		{
			if (item == node.item)
			{
				break;
			}

			index++;
		}
		return index;
	}

	public function descend()
	{
		if (nodes[index].item.item_type == SLIDER)
		{
			var item = nodes[index].item;
			item.on_slide(item, -1);
		}
		else
		{
			if (nodes[index].branch != null)
			{
				higher_nodes.push(nodes);
				higher_indexes.push(index);
				nodes = nodes[index].branch;
				index = nodes[index].branch_index;
				depth++;
				on_navigate();
			}
		}
	}

	public function ascend()
	{
		if (nodes[index].item.item_type == SLIDER)
		{
			var item = nodes[index].item;
			item.on_slide(item, -1);
			// item.
		}
		else
		{
			if (depth > 0)
			{
				nodes = higher_nodes.pop();
				index = higher_indexes.pop();
				depth--;
				on_navigate();
			}
		}
	}
}

@:publicFields
@:structInit
class MenuItemConfig
{
	var item_type: MenuItemType = ACTION;
	var label: String;
	var action: () -> Void;
	var is_valid: () -> Bool = () -> return true;
	var description: Null<String> = null;
	var on_slide: Null<(item: MenuItem, amount: Float) -> Float> = null;
	var on_select: Null<MenuItem -> Void> = null;
	var on_actioned: Null<MenuItem -> Void> = null;
	var on_reset: Null<MenuItem -> Void> = null;
	var sub_items: Array<MenuItemConfig> = null;
}

enum MenuItemType
{
	LABEL;
	ACTION;
	OPTION;
	SLIDER;
}

@:publicFields
@:structInit
class MenuItem
{
	var item_type: MenuItemType = ACTION;
	var label: String;
	var action: () -> Void;
	var is_valid: () -> Bool = () -> return true;
	var description: Null<String> = null;
	var on_select: Null<MenuItem -> Void> = null;
	var on_slide: Null<(item: MenuItem, amount: Float) -> Float> = null;
	var on_actioned: Null<MenuItem -> Void> = null;
	var on_reset: Null<MenuItem -> Void> = null;
}

@:publicFields
@:structInit
class MenuEvents
{
	var on_descend: (item: MenuItem, depth: Int) -> Bool;
	var on_ascend: (item: MenuItem, depth: Int) -> Bool;
	var on_perform_action: (item: MenuItem, depth: Int) -> Bool;
}
