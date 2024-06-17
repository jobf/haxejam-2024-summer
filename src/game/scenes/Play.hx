package game.scenes;

import lib.ldtk.TileMapping;
import lib.peote.Camera;
import lib.peote.Elements;
import lib.pure.Bresenham;
import lib.pure.Cache;
import lib.pure.Calculate;
import lib.pure.Rectangle;
import lime.ui.MouseButton;
import lime.utils.Assets;
import peote.view.Color;
import slide.Slide;
import game.Configurations;
import game.Core;
import game.LdtkData;
import game.Level;
import game.MonsterSprites;
import game.actor.*;
import game.actor.Enemy.Summon;

using lib.peote.TextureTools;

class Play extends GameScene
{
	var blanks: Blanks;
	var tiles_level: Tiles;
	var hero: Magician;
	var monster_sprites: MonsterSprites;
	var particles: BlanksParticles;
	var projectile_sprites: Sprites;
	var monsters: Array<Enemy>;
	var level: Level;
	var camera: Camera;
	var monster_projectiles: Cache<Projectile>;
	var summon: Summon;
	var start_x = 150;
	var start_y = 150;

	var end_x = 150;
	var end_y = 150;
	var exit_tile: Tile;
	var is_starting_next_level: Bool = false;
	var is_game_over: Bool = false;

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
		is_game_over = false;
		is_starting_next_level = false;
		var tile_size = 16;
		var scale = 4;
		var cell_size = tile_size * scale;

		var tiles_asset = Assets.getImage("assets/dungeon-tiles-16.png");
		var tiles_texture = tiles_asset.tilesheet_from_image(tile_size, tile_size);
		tiles_level = new Tiles(
			core.screen.display_level_tiles,
			tiles_texture,
			"tiles",
			cell_size,
			cell_size
		);
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

		blanks = new Blanks(core.screen.display_level_tiles);

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

		var levels = new LdtkData();

		var debug_level_collisions = false;

		var level_index = 2; // boss level
		var level_index = 1; // test level
		var level_index = Global.level_index;

		if (level_index == 2)
		{
			core.sound.play_music("assets/bgm_boss.ogg");
		}
		else
		{
			core.sound.play_music("assets/bgm.ogg");
		}
		// 0 is level 1
		// 2 is level 2
		// 4 is final arena
		// for(level in levels.all_worlds.Default.levels){
		// 	trace(level);
		// }

		level = new Level(levels.all_worlds.Default.levels[Global.levels[level_index]], cell_size);
		if (debug_level_collisions)
		{
			var level_tile_offset = 0;
			var debug_color: Color = Colors.YELLOW;
			debug_color.a = 0x55;
			iterate_grid(level.data.l_Collision, (value, column, row) ->
			{
				blanks.make_aligned(column, row, cell_size, cell_size, cell_size, debug_color, level_tile_offset);
			});
		}

		iterate_layer(level.data.l_Tiles, (tile_stack, column, row) ->
		{
			// get the top tile of the stack only
			var tile = tile_stack[tile_stack.length - 1];
			var is_flipped_x = tile.flipBits == 1;
			tiles_level.make_aligned(column, row, cell_size, tile.tileId, is_flipped_x);
		});

		iterate_layer(level.data.l_Decoration, (tile_stack, column, row) ->
		{
			// get the top tile of the stack only
			var tile = tile_stack[tile_stack.length - 1];
			var is_flipped_x = tile.flipBits == 1;
			tiles_level.make_aligned(column, row, cell_size, tile.tileId, is_flipped_x);
		});

		for (entity in level.data.l_Entities.all_Mechanisms)
		{
			switch entity.f_Mechanism
			{
				case Start:
					start_x = entity.cx * cell_size;
					start_y = entity.cy * cell_size;
				case End:
					end_x = entity.cx * cell_size;
					end_y = entity.cy * cell_size;
					exit_tile = tiles_level.make_aligned(entity.cx, entity.cy, cell_size, 9, true);
					exit_tile.tint.a = 0x00;
					tiles_level.update_element(exit_tile);
				case _:
					// case Door:
			}
		}

		for (entity in level.data.l_Entities.all_Pickups) {}

		hero = new Magician(
			core,
			start_x,
			start_y,
			cell_size,
			monster_sprites.get_sprites(_16),
			blanks,
			projectile_sprites,
			level,
			summon
		);

		monsters = [
			for (entity in level.data.l_Entities.all_Monsters)
			{
				var config = Configurations.monsters[entity.f_Monster];
				if (config == null)
				{
					trace('ERROR! no config for ${entity.f_Monster}');
				}
				entity.f_Monster == Haxe ? new Boss(
					entity.cx * cell_size,
					entity.cy * cell_size,
					cell_size,
					monster_sprites.get_sprites(config.tile_size),
					blanks.make(0, 0, 16, false, Colors.HITBOX),
					config,
					monster_projectiles,
					hero,
					level,
					summon,
					monsters
				) : new Enemy(
					entity.cx * cell_size,
					entity.cy * cell_size,
					cell_size,
					monster_sprites.get_sprites(config.tile_size),
					blanks.make(0, 0, 16, false, Colors.HITBOX),
					config,
					monster_projectiles,
					hero,
					level,
					summon,
					monsters
					);
			}
		];

		var level_edge_right = level.data.l_Tiles.pxWid * scale;
		var level_edge_floor = level.data.l_Tiles.pxHei * scale;

		camera = new Camera([core.screen.display_level_tiles, core.screen.display], {
			view_width: core.screen.res_width,
			view_height: core.screen.res_height,
			boundary_left: 0,
			boundary_right: level_edge_right,
			boundary_ceiling: 0,
			boundary_floor: level_edge_floor,
			zone_center_x: hero.movement.position_x,
			zone_center_y: hero.movement.position_y,
			zone_width: 128,
			zone_height: 128
		});

		camera.center_on(hero.movement.position_x, hero.movement.position_y);
		camera.toggle_debug();

		particles = new BlanksParticles(core);
		particles.limits.width = level_edge_right;
		particles.limits.height = level_edge_floor;

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

		core.window.onMouseDown.add((x, y, button) ->
		{
			if (button == MouseButton.LEFT)
			{
				// x = (x - core.screen.display.xOffset) / core.screen.peote_view.zoom;
				// y = (y - core.screen.display.yOffset) / core.screen.peote_view.zoom;
				// particles.emit(x, y);
				hero.is_shooting = true;
			}
			// if (button == MouseButton.RIGHT)
			// {
			// 	hero.health = 0;
			// }
		});

		core.window.onMouseUp.add((x, y, button) -> if (button == MouseButton.LEFT)
		{
			// x = (x - core.screen.display.xOffset) / core.screen.peote_view.zoom;
			// y = (y - core.screen.display.yOffset) / core.screen.peote_view.zoom;
			// particles.emit(x, y);
			hero.is_shooting = false;
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
			trace('$x, $y');
			particles.emit(x, y);
		});

		if (!is_game_over && hero.is_dead && hero.rect.width == 0)
		{
			Global.spellbook = [STARMISSILE];
			is_game_over = true;
			Slide.tween(core.screen)
				.to({view_y: core.screen.view_y + core.screen.res_height}, 0.55)
				.ease(slide.easing.Quad.easeIn)
				.onComplete(() ->
				{
					Global.level_index = 0;
					core.scene_reset();
					Slide.tween(core.screen)
						.to({view_y: core.screen.view_y - core.screen.res_height}, 0.55)
						.ease(slide.easing.Quad.easeIn)
						.start();
				}) // todo - show death screen?
				.start();
		}

		if (hero.inventory.is_enabled)
		{
			return;
		}

		if (exit_tile != null && exit_tile.tint.a == 0xff)
		{
			var distance_to_exit = distance_to_point(hero.rect.x, hero.rect.y, exit_tile.x, exit_tile.y);

			trace('checking exit $distance_to_exit');

			if (distance_to_exit < 50 && !is_starting_next_level)
			{
				is_starting_next_level = true;
				if (Global.level_index == Global.levels[Global.levels.length - 1])
				{
					trace('you finished the game');
				}
				else
				{
					Global.level_index++;
					core.scene_reset();
				}
			}
		}

		for (projectile in monster_projectiles.cached_items)
		{
			if (!projectile.is_waiting)
			{
				projectile.item.update(elapsed_seconds);

				projectile.item.hit_box.overlap_with(projectile.item.overlap, hero.hit_box);
				if (projectile.item.overlap.width != 0 || projectile.item.overlap.height != 0)
				{
					trace('hit!');
					projectile.item.is_expired = true;
					hero.damage(projectile.item.damage_amount);
					particles.emit(hero.rect.x, hero.rect.y);
					// on_hit(hero.movement.position_x, hero.movement.position_y);
				}

				// var distance_to_hero = distance_to_point(
				// 	projectile.item.movement.position_x,
				// 	projectile.item.movement.position_y,
				// 	hero.movement.position_x,
				// 	hero.movement.position_y
				// );

				// if (distance_to_hero < 8)
				// {
				// 	// trace('hit!');
				// 	projectile.item.is_expired = true;
				// 	hero.damage(projectile.item.damage_amount);
				// 	particles.emit(hero.rect.x, hero.rect.y);
				// }
				if (projectile.item.is_expired)
				{
					// trace('put back in cache');
					monster_projectiles.put(projectile.item);
				}
			}
		}
		var monster_index = monsters.length;
		while (monster_index-- > 0)
		{
			var monster = monsters[monster_index];

			if (!monster.is_expired)
			{
				monster.update(elapsed_seconds);
			}

			if (monster.is_dead && monster.is_opening_exit && exit_tile.tint.a != 0xff)
			{
				trace('make exit appear');
				exit_tile.tint.a = 0xff;
				tiles_level.update_element(exit_tile);
			}
		}

		particles.update(elapsed_seconds);

		var target_width_offset = 0; // (8 / 2);
		var target_height_offset = 0; // (8 / 2);
		var target_left = hero.rect.x - target_width_offset;
		var target_right = hero.rect.x + target_width_offset;
		var target_ceiling = hero.rect.y - target_height_offset;
		var target_floor = hero.rect.y + target_height_offset;
		camera.follow_target(target_left, target_right, target_ceiling, target_floor);
	}

	override function draw()
	{
		if (!hero.inventory.is_enabled)
		{
			hero.draw();

			for (enemy in monsters)
			{
				enemy.draw();
			}

			for (projectile in monster_projectiles.cached_items)
			{
				projectile.item.sprite.tint.a = Std.int(projectile.item.alpha * 0xff);
				projectile.item.draw();
			}
			blanks.update_all();
			projectile_sprites.update_all();
			monster_sprites.draw();
			camera.draw();
		}
	}

	override function clean_up()
	{
		blanks.clear();
		tiles_level.clear();
		// hero.clear();
		monster_sprites.clear();
		particles.blanks.clear();
		projectile_sprites.clear();
	}
}
