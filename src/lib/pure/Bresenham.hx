package lib.pure;

/**
	Implenmtation based on deepnight blog post from 2013 see - https://deepnight.net/tutorial/bresenham-magic-raycasting-line-of-sight-pathfinding/
**/
function is_line_blocked(x0: Int, y0: Int, x1: Int, y1: Int, has_tile_at: (grid_x: Int, grid_y: Int) -> Bool): Bool
{
	var is_x_y_swapped = Math.abs(y1 - y0) > Math.abs(x1 - x0);
	var temp: Int;
	if (is_x_y_swapped)
	{
		// swap x and y
		temp = x0;
		x0 = y0;
		y0 = temp; // swap x0 and y0
		temp = x1;
		x1 = y1;
		y1 = temp; // swap x1 and y1
	}

	if (x0 > x1)
	{
		// make sure x0 < x1
		temp = x0;
		x0 = x1;
		x1 = temp; // swap x0 and x1
		temp = y0;
		y0 = y1;
		y1 = temp; // swap y0 and y1
	}

	var delta_x = x1 - x0;
	var delta_y = Math.floor(Math.abs(y1 - y0));
	var error = Math.floor(delta_x / 2);
	var y = y0;
	var y_step = if (y0 < y1) 1 else -1;

	if (is_x_y_swapped)
		// Y / X
		for (x in x0...x1 + 1)
		{
			if (has_tile_at(y, x))
				// line is blocked
				return true;

			error -= delta_y;
			if (error < 0)
			{
				y = y + y_step;
				error = error + delta_x;
			}
		}
	else
		// X / Y
		for (x in x0...x1 + 1)
		{
			if (has_tile_at(x, y))
				// line is blocked
				return true;

			error -= delta_y;
			if (error < 0)
			{
				y = y + y_step;
				error = error + delta_x;
			}
		}

	// line is not blocked
	return false;
}
