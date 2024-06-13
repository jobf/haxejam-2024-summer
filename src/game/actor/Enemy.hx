package game.actor;

import lib.peote.Elements;
import game.Configurations;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;
	var attention_duration: Float = 1.25;
	var attention_timer: Float = 1.25;

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

		speed = 130;
		movement.velocity_max_x = 100;
		movement.velocity_max_y = 100;

		movement.deceleration_x = 4000;
		movement.deceleration_x = 4000;
	}

	override function update(elapsed_seconds: Float, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		super.update(elapsed_seconds, has_wall_tile_at);
		if (health <= 0)
		{
			sprite.tile_index = Configurations.spells[config.drop].tile_index;
		}
		else
		{
			if (is_moving())
			{
				attention_timer -= elapsed_seconds;
				if (attention_timer <= 0)
				{
					movement.acceleration_x = 0;
					movement.acceleration_y = 0;
					attention_timer = attention_duration;
				}
			}
		}
	}

	public function move_towards_angle(angle: Float)
	{
		// trace(sprite.angle);
		movement.acceleration_x = Math.cos(angle) * speed;
		movement.acceleration_y = Math.sin(angle) * speed;
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
