package game.actor;

import game.Configurations;
import game.Inventory.SpellConfig;
import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.Countdown;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;
	var stop_moving_countdown: Countdown;
	var shooting_countdown: Countdown;

	var cache: Cache<Projectile>;

	var target_angle: Null<Float> = null;
	var spell_config:SpellConfig;

	function new(x: Float, y: Float, cell_size: Int, sprites: Sprites, config: EnemyConfig, cache: Cache<Projectile>)
	{
		this.cache = cache;
		this.config = config;
		this.spell_config = Configurations.spells[config.drop];
		
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

		stop_moving_countdown = new Countdown(1.25, countdown ->
		{
			this.movement.acceleration_x = 0;
			this.movement.acceleration_y = 0;
		});

		shooting_countdown = new Countdown(2.25, countdown ->
		{
			if (target_angle != null)
			{
				this.cast_spell();
			}
		});
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
				stop_moving_countdown.update(elapsed_seconds);
			}
			shooting_countdown.update(elapsed_seconds);
		}
	}

	function target(angle: Float)
	{
		this.target_angle = angle;
		move_towards_angle(angle);
	}

	function move_towards_angle(angle: Float)
	{
		// trace(sprite.angle);
		movement.acceleration_x = Math.cos(angle) * speed;
		movement.acceleration_y = Math.sin(angle) * speed;
	}

	function cast_spell()
	{
		var projectile = cache.get();
		if (projectile != null)
		{
			projectile.reset(
				movement.position_x,
				movement.position_y,
				1,
				spell_config
			);
			projectile.move_towards_angle(target_angle);
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
