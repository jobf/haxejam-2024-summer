package game.actor;

import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.Calculate;
import lib.pure.Countdown;
import lib.pure.Rectangle;
import game.Configurations;
import game.Inventory;
import game.LdtkData;
import game.actor.Enemy;

class Magician extends Actor
{
	var cache: Cache<Projectile>;
	var scroll: Sprite;
	var mouse_angle: Float;
	var inventory: Inventory;
	var spell_countdown: Countdown;
	var is_shooting: Bool = false;
	var summon: Summon;
	var health_bar: HealthBar;
	var core: Core;
	public function new(core: Core, x: Float, y: Float, cell_size: Int, sprites: Sprites, blanks: Blanks, projectile_sprites: Sprites, level: Level,
			summon: Summon)
	{
		this.core = core;
		cache = {
			cached_items: [],
			create: () -> new Projectile(
				cell_size,
				projectile_sprites.make(0, 0, 512),
				blanks.make(0, 0, 8, false, Colors.HITBOX),
				level
			),
			cache: projectile -> projectile.hide(),
			item_limit: 15,
		};
		this.summon = summon;
		var animation_tile_indexes = [32, 33];
		super(
			cell_size,
			sprites.make(
				x,
				y,

				animation_tile_indexes[0]
			),
			blanks.make(0, 0, 8, false, Colors.HITBOX),
			animation_tile_indexes,
			level
		);
		health = 100;

		this.health_bar = new HealthBar(
			rect.x - rect.width / 2,
			rect.y - hit_box.height / 2,
			health,
			blanks
		);
		debug_hit_box.width = Std.int(hit_box.width);
		debug_hit_box.height = Std.int(hit_box.height);
		var scroll_tile_index = 34;
		scroll = sprites.make(x, y, scroll_tile_index);
		inventory = new Inventory(core);
		for (key in Global.spellbook)
		{
			inventory.make_available(key);
		}
		inventory.activate(STARMISSILE);
		inventory.toggle_visibility();

		spell_countdown = new Countdown(inventory.spell_config.cool_down, countdown ->
		{
			if (is_shooting)
			{
				cast_spell(facing);
			}

			countdown.duration = this.inventory.spell_config.cool_down;
		});
	}

	function toggle_shooting(is_shooting: Bool)
	{
		this.is_shooting = is_shooting;
		if (this.is_shooting)
		{
			spell_countdown.remaining = -10;
		}
	}

	function update_(elapsed_seconds: Float, monsters: Array<Enemy>, on_hit: (x: Float, y: Float) -> Void)
	{
		super.update(elapsed_seconds);
		inventory.update();

		if (inventory.is_enabled)
		{
			return;
		}
		health_bar.move(rect.x, rect.y);
		scroll.x -= movement.position_previous_x - movement.position_x;
		scroll.y -= movement.position_previous_y - movement.position_y;
		spell_countdown.update(elapsed_seconds);
		for (projectile in cache.cached_items)
		{
			if (!projectile.is_waiting)
			{
				projectile.item.update(elapsed_seconds);
				for (monster in monsters)
				{
					if (monster.is_expired || monster.is_dead)
					{
						trace('monster.is_expired');
						continue;
					}
					projectile.item.hit_box.overlap_with(projectile.item.overlap, monster.hit_box);
					if (projectile.item.overlap.width != 0 || projectile.item.overlap.height != 0)
					{
						trace('hit!');
						projectile.item.is_expired = true;
						monster.damage(inventory.spell_config.damage);
						on_hit(monster.rect.x, monster.rect.y);
						// on_hit(monster.movement.position_x, monster.movement.position_y);
					}
				}
				if (projectile.item.is_expired)
				{
					// trace('put back in cache');
					cache.put(projectile.item);
				}
			}
		}
	}

	override function draw()
	{
		super.draw();
		for (projectile in cache.cached_items)
		{
			projectile.item.sprite.tint.a = Std.int(projectile.item.alpha * 0xff);
			projectile.item.draw();
		}
	}

	public function cast_spell(facing_x: Int)
	{
		trace('magician cast spell');
		var is_summon = false;
		for (button in inventory.active_slots)
		{
			if (button.config.key == SKELETON)
			{
				is_summon = true;
			}
		}
		if (is_summon)
		{
			var angle = radians_between(rect.x, rect.y, scroll.x, scroll.y) - 180;
			var x = rect.x + Math.sin(angle) * 200;
			var y = rect.y + Math.cos(angle) * 200;

			var key = Skeleton; // inventory.spell_config.key == SKELETON ? Skeleton : Dragon;
			var monster = summon(Skeleton, x, y);
			monster.animation_tile_indexes = [70, 71];
			monster.is_summoned_by_hero = true;
			trace(monster.health);
			core.sound.play_sound(Configurations.sounds[SpellType.SKELETON]);
		}
		else
		{
			var projectile = cache.get();
			if (projectile != null)
			{
				projectile.reset(
					sprite.x,
					sprite.y,
					facing_x,
					inventory.spell_config
				);
				projectile.move_towards_angle(mouse_angle);

				core.sound.play_sound(Configurations.sounds[inventory.spell_config.key]);
			}
		}
	}

	public function scroll_follow_mouse(x: Float, y: Float)
	{
		mouse_angle = radians_between(
			x,
			y,
			movement.position_x,
			movement.position_y
		);
		// scroll.x = movement.position_x + Math.sin(mouse_angle) * 60;
		// scroll.y = movement.position_y + Math.cos(mouse_angle) * 60;

		scroll.x = rect.x + Math.sin(mouse_angle) * 60;
		scroll.y = rect.y + Math.cos(mouse_angle) * 60;
		// trace('scroll_follow_mouse radians $mouse_angle');
	}

	override function damage(amount: Float)
	{
		super.damage(amount);
		health_bar.change_health(health);
		trace('hero damage $amount remain $health');
	}
}

@:publicFields
class HealthBar
{
	var width: Float = 100;
	var height: Float = 12;
	var back: Blank;
	var front: Blank;
	var max: Float;
	var x_offset: Float = 0;
	var y_offset: Float = 70;

	function new(x: Float, y: Float, max: Float, blanks: Blanks)
	{
		this.max = max;
		// this.blanks = blanks;
		back = blanks.rect(x + x_offset, y + y_offset, max + 4, height, 0xffffffAA, true);
		front = blanks.rect(x + x_offset, y + y_offset, max, height - 4, 0xff3030AA, true);
	}

	function move(x: Float, y: Float)
	{
		back.x = x + x_offset;
		back.y = y + y_offset;
		front.x = x + x_offset;
		front.y = y + y_offset;
	}

	function change_health(next: Float)
	{
		if (next > 0)
		{
			front.width = Std.int(next); // Std.int((amount / max) * front_width);
		}
		else
		{
			front.width = Std.int(0);
		}
	}
}
