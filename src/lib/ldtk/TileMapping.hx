package lib.ldtk;

import ldtk.Layer_IntGrid;
import ldtk.Layer_Tiles;

function iterate_layer(layer: Layer_Tiles, iterate_tile_stack: (stack: Array<{tileId: Int, flipBits: Int}>, column: Int, row: Int) -> Void): Void
{
	for (cy in 0...layer.cHei)
	{
		for (cx in 0...layer.cWid)
		{
			if (layer.hasAnyTileAt(cx, cy))
			{
				// trace('tile at $cx $cy');
				iterate_tile_stack(
					layer.getTileStackAt(cx, cy),
					cx,
					cy
				);
			}
		}
	}
}

function iterate_layer_portion(layer: Layer_Tiles, start_column: Int, start_row: Int, end_column: Int, end_row: Int,
		iterate_tile_stack: (stack: Array<{tileId: Int, flipBits: Int}>, column: Int, row: Int) -> Void): Void
{
	for (cy in start_row...end_row)
	{
		for (cx in start_row...end_column)
		{
			if (layer.hasAnyTileAt(cx, cy))
			{
				// trace('tile at $cx $cy');
				iterate_tile_stack(
					layer.getTileStackAt(cx, cy),
					cx,
					cy
				);
			}
		}
	}
}

function iterate_grid(layer: Layer_IntGrid, iterate_value: (value: Int, column: Int, row: Int) -> Void): Void
{
	for (cy in 0...layer.cHei)
	{
		for (cx in 0...layer.cWid)
		{
			if (layer.hasValue(cx, cy))
			{
				iterate_value(
					layer.getInt(cx, cy),
					cx,
					cy
				);
			}
		}
	}
}
