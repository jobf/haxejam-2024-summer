package game.actor;

import lib.peote.Elements;
import lib.pure.Bresenham;
import lib.pure.Cache;
import lib.pure.Calculate;
import lib.pure.Countdown;
import game.Configurations;
import game.Inventory.SpellConfig;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;
	var stop_moving_countdown: Countdown;
	var shooting_countdown: Countdown;
	var spell_countdown:Countdown;

	var cache: Cache<Projectile>;

	var target_angle: Null<Float> = null;
	var spell_config: SpellConfig;
	var hero: Magician;
	var is_shooting: Bool = false;

	function new(x: Float, y: Float, cell_size: Int, sprites: Sprites, config: EnemyConfig, cache: Cache<Projectile>, hero: Magician)
	{
		this.cache = cache;
		this.hero = hero;
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

		health = config.health;
		speed = config.speed;
		movement.velocity_max_x = config.velocity_max;
		movement.velocity_max_y = config.velocity_max;

		movement.deceleration_x = config.deceleration;
		movement.deceleration_y = config.deceleration;

		stop_moving_countdown = new Countdown(config.movement_duration, countdown ->
		{
			this.movement.acceleration_x = 0;
			this.movement.acceleration_y = 0;
		});

		shooting_countdown = new Countdown(config.shooting_duration, countdown ->
		{
			if (is_shooting)
			{
				is_shooting = false;
			}
		});

		spell_countdown = new Countdown(spell_config.cool_down, countdown ->
		{
			if (is_shooting)
			{
				cast_spell();
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
			spell_countdown.update(elapsed_seconds);

			var x_grid_distance = Math.abs(hero.movement.column - movement.column);
			var y_grid_distance = Math.abs(hero.movement.row - movement.row);
			// fast distance check - is distance close enough to be seen?
			var do_line_of_sight_check = x_grid_distance <= config.sight_grid_limit && y_grid_distance <= config.sight_grid_limit;
			if (do_line_of_sight_check)
			{
				var is_hero_in_sight = !is_line_blocked(
					hero.movement.column,
					hero.movement.row,
					movement.column,
					movement.row,
					has_wall_tile_at // (grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
				);
				// monster.sprite.tint.a = 0xff;
				if (is_hero_in_sight)
				{
					// monster.sprite.tint.a = 0x40;
					target_angle = Math.atan2(hero.movement.position_y - movement.position_y, hero.movement.position_x - movement.position_x);
					move_towards_angle(target_angle);
					is_shooting = true;
				}
				else
				{
					target_angle = null;
				}
			}
			// todo (better distance check for overlap)
			var is_overlapping_hero = x_grid_distance == 0 && y_grid_distance == 0; // hero.movement.column == monster.movement.column && hero.movement.row == monster.movement.row;

			if (is_overlapping_hero)
			{
				if (health <= 0)
				{
					trace('pick up spell!');
					hero.inventory.make_available(config.drop);
					is_expired = true;
					sprite.tint.a = 0;
					// enemies.remove(monster);
				}
				else
				{
					hero.damage(1); // todo - proper damage
				}
			}
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
			var angle = radians_between(
				hero.movement.position_x,
				hero.movement.position_y,
				movement.position_x,
				movement.position_y
			);
			projectile.move_towards_angle(angle);
		}
	}
}
