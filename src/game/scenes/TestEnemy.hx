package game.scenes;

import lib.ldtk.TileMapping;
import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import peote.view.Color;
import game.Colors;
import game.Configurations;
import game.Core;
import game.LdtkData;
import game.actor.*;
import game.actor.Enemy.Summon;

using lib.peote.TextureTools;

class TestEnemy extends GameScene
{
	var level: Level;
	var sprites: Sprites;
	var hero: Magician;
	var monster_sprites: MonsterSprites;
	var monsters: Array<Enemy>;
	var monster_projectiles: Cache<Projectile>;
	var projectile_sprites: Sprites;
	var particles: BlanksParticles;
	var blanks: Blanks;
	var summon: Summon;

	public function new(core: Core)
	{
		super(core, {
			introduction: ["testing"],
			items: [
				{
					item_type: ACTION,
					label: "reset scene",
					action: () -> core.scene_reset(),
					is_valid: () -> true,
					description: "",
					on_select: item -> trace("select"),
					on_actioned: item -> trace("action"),
					on_reset: item -> trace("reset"),
					// sub_items:
				},
			],

			// is_aligned_to_bottom: false,
			on_close: () -> trace('menu_closed')
		});
	}

	override function begin()
	{
		super.begin();

		var template_asset = Assets.getImage("assets/sprites-16.png");
		var tile_size = 16;
		var sprite_texture = template_asset.tilesheet_from_image(tile_size, tile_size);
		var scale = 4;
		var cell_size = tile_size * scale;

		var levels = new LdtkData();
		var level_index = 3; // empty level
		level = new Level(levels.all_worlds.Default.levels[level_index], cell_size);

		sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"sprites",
			cell_size,
			cell_size
		);
		monster_sprites = new MonsterSprites(core, scale);

		var sprite_asset = Assets.getImage("assets/sprites-16.png");
		var sprite_texture = sprite_asset.tilesheet_from_image(tile_size, tile_size);
		projectile_sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"projectiles",
			tile_size * 2,
			tile_size * 2
		);

		particles = new BlanksParticles(core);
		particles.limits.width = core.screen.res_width;
		particles.limits.height = core.screen.res_height;
		blanks = new Blanks(core.screen.display);
		monster_projectiles = {
			cached_items: [],
			create: () -> new Projectile(
				cell_size,
				projectile_sprites.make(0, 0, 512),
				blanks.make(0, 0, 16, false, Colors.HITBOX),
				level
			),
			cache: projectile -> projectile.hide(),
			item_limit: 250,
		};

		summon = (key, x, y) ->
		{
			var config = Configurations.monsters[key];
			var monster = new Enemy(
				x,
				y,
				cell_size,
				monster_sprites.get_sprites(config.tile_size),
				blanks.make(0, 0, 16, false, Colors.HITBOX),
				config,
				monster_projectiles,
				hero,
				level,
				this.summon,
				monsters
			);
			monster.can_move = false;
			monsters.push(monster);
			return monster;
		}

		hero = new Magician(
			core,
			750,
			50,
			cell_size,
			monster_sprites.get_sprites(_16),
			blanks,
			projectile_sprites,
			level,
			summon
		);
		hero.inventory.make_available(FIREBALL);
		hero.inventory.make_available(PUNCH);
		hero.inventory.make_available(BONESPEAR);
		hero.inventory.make_available(BOLT);
		hero.inventory.make_available(DRAGON);
		hero.inventory.make_available(INFEST);
		hero.inventory.make_available(LIGHTNING);
		hero.inventory.make_available(SKELETON);

		monsters = [];
		summon(Skeleton, 100, 100);
		summon(Zombie, 175, 100);
		summon(Necromancer, 250, 100);
		summon(
			Dragon_Tamer_Priestess,
			325,
			100
		);
		summon(Dragon, 170, 350);
		summon(Dragon_Electro, 450, 350);
		summon(Dragon_Fire, 730, 350);
		var level_tile_offset = 0;
		var debug_color: Color = Colors.YELLOW;
		debug_color.a = 0x55;
		iterate_grid(level.data.l_Collision, (value, column, row) ->
		{
			blanks.make_aligned(column, row, cell_size, cell_size, cell_size, debug_color, level_tile_offset);
		});
		init_controller();
	}

	function init_controller()
	{
		controller.left.on_press = () -> hero.move_in_direction_x(-1);
		controller.left.on_release = () -> hero.stop_x();

		controller.right.on_press = () -> hero.move_in_direction_x(1);
		controller.right.on_release = () -> hero.stop_x();

		controller.up.on_press = () -> hero.move_in_direction_y(-1);
		controller.up.on_release = () -> hero.stop_y();

		controller.down.on_press = () -> hero.move_in_direction_y(1);
		controller.down.on_release = () -> hero.stop_y();

		controller.a.on_press = () -> hero.dash();
		controller.b.on_press = () -> hero.inventory.toggle_visibility();

		core.input.change_target(controller);

		core.window.onMouseDown.add((x, y, button) -> if (button == MouseButton.LEFT)
		{
			hero.toggle_shooting(true);
		});

		core.window.onMouseUp.add((x, y, button) -> if (button == MouseButton.LEFT)
		{
			hero.toggle_shooting(false);
		});

		core.window.onMouseMove.add((x, y) ->
		{
			x = (x - core.screen.display.xOffset) / core.screen.peote_view.zoom;
			y = (y - core.screen.display.yOffset) / core.screen.peote_view.zoom;
			hero.scroll_follow_mouse(x, y);
		});
	}

	override function update(elapsed_seconds: Float)
	{
		hero.update_(elapsed_seconds, monsters, (x, y) ->
		{
			particles.emit(x, y);
		});

		particles.update(elapsed_seconds);
		for (projectile in monster_projectiles.cached_items)
		{
			if (!projectile.is_waiting)
			{
				// projectile.item.update(elapsed_seconds);

				// var distance_to_hero = distance_to_point(
				// 	projectile.item.movement.position_x,
				// 	projectile.item.movement.position_y,
				// 	hero.movement.position_x,
				// 	hero.movement.position_y
				// );

				// if (distance_to_hero < 8)
				// {
				// 	trace('hit!');
				// 	projectile.item.is_expired = true;
				// 	hero.damage(1);
				// 	particles.emit(hero.movement.position_x, hero.movement.position_y);
				// }
				// if (projectile.item.is_expired)
				// {
				// 	trace('put back in cache');
				// 	monster_projectiles.put(projectile.item);
				// }


				projectile.item.update(elapsed_seconds);

				projectile.item.hit_box.overlap_with(projectile.item.overlap, hero.hit_box);
				if (projectile.item.overlap.width != 0 || projectile.item.overlap.height != 0)
				{
					trace('hit!');
					projectile.item.is_expired = true;
					// hero.damage(projectile.item.damage_amount);
					particles.emit(hero.rect.x, hero.rect.y);
				}
				if (projectile.item.is_expired)
				{
					// trace('put back in cache');
					monster_projectiles.put(projectile.item);
				}
			}
		}

		for (monster in monsters)
		{
			monster.update(elapsed_seconds);
		}
		for (projectile in monster_projectiles.cached_items)
		{
			if (!projectile.is_waiting)
			{
				projectile.item.update(elapsed_seconds);
			}
		}
	}

	override function draw()
	{
		hero.draw();
		for (monster in monsters)
		{
			monster.draw();
		}
		monster_sprites.draw();
		sprites.update_all();

		for (projectile in monster_projectiles.cached_items)
		{
			projectile.item.sprite.tint.a = Std.int(projectile.item.alpha * 0xff);
			projectile.item.draw();
		}
		projectile_sprites.update_all();
		blanks.update_all();
	}

	override function clean_up()
	{
		monster_sprites.clear();
		projectile_sprites.clear();
		sprites.clear();
	}
}
