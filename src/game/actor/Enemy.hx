package game.actor;

import lib.peote.Elements;
import game.Configurations;

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

	override function update(elapsed_seconds: Float, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		super.update(elapsed_seconds, has_wall_tile_at);
		if (health <= 0)
		{
			sprite.tile_index = Configurations.spells[config.drop].tile_index;
		}
	}
}

@:publicFields
@:structInit
class EnemyConfig
{
	var collision_radius: Float;
	var animation_tile_indexes: Array<Int>;
	var drop: SpellType;
}
