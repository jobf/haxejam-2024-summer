package game.actor;

import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.Calculate;
// import game.Configurations;
import game.Inventory;

class Magician extends Actor
{
	var cache: Cache<Projectile>;
	var scroll: Sprite;
	var mouse_angle: Float;
	var inventory: Inventory;

	public function new(core: Core, x: Float, y: Float, cell_size: Int, sprites: Sprites)
	{
		cache = {
			cached_items: [],
			create: () -> new Projectile(cell_size, sprites.make(0, 0, 512)),
			cache: projectile -> projectile.hide(),
			item_limit: 15,
		};
		health = 3;

		var animation_tile_indexes = [32, 33];
		super(
			cell_size,
			sprites.make(
				x,
				y,

				animation_tile_indexes[0]
			),
			animation_tile_indexes
		);

		var scroll_tile_index = 34;
		scroll = sprites.make(x, y, scroll_tile_index);
		inventory = new Inventory(core);
		inventory.make_available(STARMISSILE);
		inventory.activate(STARMISSILE);
		inventory.toggle_visibility();
	}

	function update_(elapsed_seconds: Float, monsters: Array<Enemy>, on_hit: (x: Float, y: Float) -> Void, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		super.update(elapsed_seconds, has_wall_tile_at);

		for (projectile in cache.cached_items)
		{
			if (!projectile.is_waiting)
			{
				projectile.item.update(elapsed_seconds, has_wall_tile_at);
				for (monster in monsters)
				{
					if (monster.is_expired)
					{
						trace('monster.is_expired');
						continue;
					}

					var distance_to_monster = distance_to_point(
						projectile.item.movement.position_x,
						projectile.item.movement.position_y,
						monster.movement.position_x,
						monster.movement.position_y
					);

					if (distance_to_monster < monster.config.collision_radius)
					{
						trace('hit!');
						projectile.item.is_expired = true;
						monster.damage(1);
						on_hit(monster.movement.position_x, monster.movement.position_y);
					}
				}
				if (projectile.item.is_expired)
				{
					trace('put back in cache');
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
		var projectile = cache.get();
		if (projectile != null)
		{
			projectile.reset(
				movement.position_x,
				movement.position_y,
				facing_x,
				inventory.spell_config
			);
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
}
