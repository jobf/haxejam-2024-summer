package game.actor;

import lib.peote.Elements;
import lib.pure.Bresenham;
import lib.pure.Cache;
import lib.pure.Calculate;
import lib.pure.Countdown;
import lib.pure.Rectangle;
import slide.Slide;
import game.Configurations;
import game.LdtkData;

typedef Summon = (key: Enum_Monster, x: Float, y: Float) -> Enemy;

@:publicFields
class Enemy extends Actor
{
	var config: EnemyConfig;
	var stop_moving_countdown: Countdown;
	var shooting_countdown: Countdown;
	var spell_countdown: Countdown;

	var cache: Cache<Projectile>;

	var target_angle: Null<Float> = null;
	var spell_config: SpellConfig;
	var hero: Magician;
	var is_shooting: Bool = false;
	var summon: Summon;
	var is_summoned_by_hero: Bool = false;
	var enemies: Array<Enemy>;
	var is_opening_exit: Bool = false;
	var is_spell: Bool = false;

	function new(x: Float, y: Float, cell_size: Int, sprites: Sprites, debug_hit_box: Blank, config: EnemyConfig, cache: Cache<Projectile>, hero: Magician,
			level: Level, summon: Summon, enemies: Array<Enemy>)
	{
		this.cache = cache;
		this.hero = hero;
		this.config = config;
		if (config.key == Necromancer)
		{
			is_opening_exit = true;
		}
		this.spell_config = Configurations.spells[config.spell];
		this.summon = summon;
		this.enemies = enemies;
		super(
			cell_size,
			sprites.make(
				x,
				y,
				config.animation_tile_indexes[0]
			),
			debug_hit_box,
			config.animation_tile_indexes,
			level
		);
		rect.width = sprite.width;
		rect.height = sprite.height;
		debug_hit_box.width = config.hit_box_w;
		debug_hit_box.height = config.hit_box_h;
		hit_box.width = config.hit_box_w;
		hit_box.height = config.hit_box_h;
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

	override function update(elapsed_seconds: Float)
	{
		super.update(elapsed_seconds);

		if(is_expired){
			return;
		}
		
		if (is_dead)
		{
			if (rect.width == 0)
			{
				sprite.tile_index = Configurations.spells[config.spell].tile_index;
				Slide.tween(rect).to({width: 64.0}, 0.25).ease(slide.easing.Quad.easeOut).start();
				return;
			}

			var distance_to_hero = distance_to_point(
				hero.movement.position_x,
				hero.movement.position_y,
				movement.position_x,
				movement.position_y
			);

			var is_overlapping_hero = distance_to_hero < 40;

			if (is_overlapping_hero)
			{
				trace('pick up spell!');
				hero.inventory.make_available(config.spell);
				is_expired = true;
				sprite.tint.a = 0;
				// enemies.remove(monster);
				// hero.damage(Configurations.spells[config.spell].damage); // todo - proper damage
			}
		}
		else
		{
			if (is_moving())
			{
				stop_moving_countdown.update(elapsed_seconds);
			}
			shooting_countdown.update(elapsed_seconds);
			spell_countdown.update(elapsed_seconds);

			if (is_summoned_by_hero)
			{
				for (monster in enemies)
				{
					var x_grid_distance = Math.abs(monster.movement.column - movement.column);
					var y_grid_distance = Math.abs(monster.movement.row - movement.row);
					// fast distance check - is distance close enough to be seen?
					var do_line_of_sight_check = x_grid_distance <= config.sight_grid_limit && y_grid_distance <= config.sight_grid_limit;
					if (do_line_of_sight_check)
					{
						var is_monster_in_sight = !is_line_blocked(
							monster.movement.column,
							monster.movement.row,
							movement.column,
							movement.row,
							level.is_wall_cell // (grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
						);
						// monster.sprite.tint.a = 0xff;
						if (is_monster_in_sight)
						{
							// monster.sprite.tint.a = 0x40;
							target_angle = Math.atan2(monster.movement.position_y - movement.position_y, monster.movement.position_x - movement.position_x);
							move_towards_angle(target_angle);
							is_shooting = true;
						}
						else
						{
							target_angle = null;
						}
					}
					// todo (better distance check for overlap)
					var is_overlapping_monster = x_grid_distance == 0 && y_grid_distance == 0; // monster.movement.column == monster.movement.column && monster.movement.row == monster.movement.row;

					if (is_overlapping_monster)
					{
						monster.damage(Configurations.spells[config.spell].damage); // todo - proper damage
					}
				}
			}
			else
			{
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
						level.is_wall_cell // (grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
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
		if (spell_config.key == SKELETON) // || spell_config.key == DRAGON)
		{
			var angle = radians_between(
				hero.movement.position_x,
				hero.movement.position_y,
				movement.position_x,
				movement.position_y
			);
			var x = movement.position_x + Math.sin(angle) * 100;
			var y = movement.position_y + Math.cos(angle) * 100;

			summon(Skeleton, x, y);
			trace('summon skeleton $x $y');
		}
		else
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
}
