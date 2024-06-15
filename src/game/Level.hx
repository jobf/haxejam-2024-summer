package game;

import lib.pure.Rectangle;
import game.LdtkData;

@:publicFields
class Level
{
	var data: LdtkData_Level;
	var wall_rect: Rectangle;
	var cell_size: Int;

	function new(data: LdtkData_Level, cell_size: Int)
	{
		this.data = data;
		this.cell_size = cell_size;
		wall_rect = {
			x: 0,
			y: 0,
			width: cell_size,
			height: cell_size,
		}
	}

	function wall_rect_at(x: Float, y: Float): Null<Rectangle>
	{
		var column = Std.int(x / cell_size);
		var row = Std.int(y / cell_size);
		if (data.l_Collision.hasValue(column, row))
		{
			wall_rect.x = column * cell_size;
			wall_rect.y = row * cell_size;
			return wall_rect;
		}
		return null;
	}

	function is_wall_cell(column: Int, row: Int): Bool
	{
		return data.l_Collision.hasValue(column, row);
	}
}
