package game.actor;

import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.Calculate;

class Magician extends Actor
{
	var cache: Cache<Projectile>;
	var scroll: Sprite;
	var mouse_angle: Float;

	public function new(x: Float, y: Float, sprites: Sprites)
	{
		cache = {
			cached_items: [],
			create: () -> new Projectile({
				sprite: sprites.make(0, 0, 512),
			}),
			cache: projectile -> projectile.sprite.tint.a = 0,
			item_limit: 15,
		};

		var animation_tile_indexes = [32, 33];
		super(sprites.make(
			x,
			y,
			animation_tile_indexes[0]
		), animation_tile_indexes);

		var scroll_tile_index = 34;
		scroll = sprites.make(x, y, scroll_tile_index);
	}

	function update_(elapsed_seconds: Float, targets: Array<Enemy>)
	{
		super.update(elapsed_seconds);
		for (cached in cache.cached_items)
		{
			if (!cached.is_waiting)
			{
				cached.item.update(elapsed_seconds);
				for (target in targets)
				{
					if (target.is_expired)
					{
						continue;
					}

					var distance_to_target = distance_to_point(
						cached.item.movement.position_x,
						cached.item.movement.position_y,
						target.movement.position_x,
						target.movement.position_y
					);

					if (distance_to_target < target.config.collision_radius)
					{
						trace('hit!');
						cached.item.is_expired = true;
						target.damage(1);
					}
				}
				if (cached.item.is_expired)
				{
					// trace('put back in cache');
					cache.put(cached.item);
				}
			}
		}
	}

	override function draw()
	{
		super.draw();
		for (cached in cache.cached_items)
		{
			if (!cached.is_waiting)
			{
				cached.item.sprite.tint.a = Std.int(cached.item.alpha * 0xff);
				cached.item.draw();
			}
		}
	}

	public function cast_spell(facing_x: Int)
	{
		var projectile = cache.get();
		if (projectile != null)
		{
			projectile.reset(scroll.x, scroll.y, facing_x);
			projectile.sprite.tile_index = 0;
			projectile.move_towards_angle(mouse_angle);
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
		scroll.x = movement.position_x + Math.sin(mouse_angle) * 60;
		scroll.y = movement.position_y + Math.cos(mouse_angle) * 60;
		// trace('scroll_follow_mouse radians $mouse_angle');
	}

	public function show_spells() {}
}
