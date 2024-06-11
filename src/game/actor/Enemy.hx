package game.actor;

import lib.peote.Elements;

@:publicFields
class Enemy extends Actor
{
	function new(x: Float, y: Float, sprites: Sprites)
	{
		var animation_tile_indexes = [67, 68];
		super(sprites.make(
			x,
			y,
			animation_tile_indexes[0]
		), animation_tile_indexes);
	}
}

@:publicFields
@:structInit
class EnemyConfig
{
	var collision_radius: Float;
	var animation_tile_indexes: Array<Int>;
}
