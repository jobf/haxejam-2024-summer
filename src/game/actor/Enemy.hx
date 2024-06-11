package game.actor;

import lib.peote.Elements;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;

	function new(x: Float, y: Float, sprites: Sprites, config: EnemyConfig)
	{
		this.config = config;
		super(sprites.make(
			x,
			y,
			config.animation_tile_indexes[0]
		), config.animation_tile_indexes);
	}
}

@:publicFields
@:structInit
class EnemyConfig
{
	var collision_radius: Float;
	var animation_tile_indexes: Array<Int>;
}
