package game.actor;

import lib.peote.Elements;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;

	function new(x: Float, y: Float, cell_size: Int, sprites: Sprites, config: EnemyConfig)
	{
		this.config = config;
		super(
			cell_size,
			sprites.make(
				x,
				y,
				config.animation_tile_indexes[0]
			),
			config.animation_tile_indexes
		);
	}
}

@:publicFields
@:structInit
class EnemyConfig
{
	var collision_radius: Float;
	var animation_tile_indexes: Array<Int>;
}
