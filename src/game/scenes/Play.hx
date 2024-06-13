package game.scenes;

import lib.ldtk.TileMapping;
import lib.peote.Camera;
import lib.peote.Elements;
import lib.pure.Bresenham;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import peote.view.Color;
import game.Configurations;
import game.Core;
import game.LdtkData;
import game.actor.*;

using lib.peote.TextureTools;

class Play extends GameScene
{
	var blanks: Blanks;
	var tiles_level: Tiles;
	var sprites: Sprites;
	var hero: Magician;
	var enemies: Array<Enemy>;
	var level: LdtkData_Level;
	var camera: Camera;
	var particles: BlanksParticles;

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
		var tile_size = 16;
		var scale = 4;
		var sprite_size = tile_size * scale;

		var tiles_asset = Assets.getImage("assets/dungeon-tiles-16.png");
		var tiles_texture = tiles_asset.tilesheet_from_image(tile_size, tile_size);
		tiles_level = new Tiles(
			core.screen.display_level_tiles,
			tiles_texture,
			"tiles",
			sprite_size,
			sprite_size
		);

		blanks = new Blanks(core.screen.display_level_tiles);

		var sprite_asset = Assets.getImage("assets/sprites-16.png");
		var sprite_texture = sprite_asset.tilesheet_from_image(tile_size, tile_size);
		sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"sprites",
			sprite_size,
			sprite_size
		);

		var levels = new LdtkData();

		var level_index = 1; // test level
		var level_index = 0;
		var debug_level_collisions = false;

		level = levels.all_worlds.Default.levels[level_index];
		if (debug_level_collisions)
		{
			var level_tile_offset = 0;
			var debug_color: Color = Colors.YELLOW;
			debug_color.a = 0x55;
			iterate_grid(level.l_Collision, (value, column, row) ->
			{
				blanks.make_aligned(column, row, sprite_size, sprite_size, sprite_size, debug_color, level_tile_offset);
			});
		}

		iterate_layer(level.l_Tiles, (tile_stack, column, row) ->
		{
			// get the top tile of the stack only
			var tile = tile_stack[tile_stack.length - 1];
			var is_flipped_x = tile.flipBits == 1;
			tiles_level.make_aligned(column, row, sprite_size, tile.tileId, is_flipped_x);
		});

		iterate_layer(level.l_Decoration, (tile_stack, column, row) ->
		{
			// get the top tile of the stack only
			var tile = tile_stack[tile_stack.length - 1];
			var is_flipped_x = tile.flipBits == 1;
			tiles_level.make_aligned(column, row, sprite_size, tile.tileId, is_flipped_x);
		});

		enemies = [
			for (entity in level.l_Entities.all_Monsters)
				new Enemy(
					entity.cx * sprite_size,
					entity.cy * sprite_size,
					sprite_size,
					sprites,
					Configurations.monsters[entity.f_Monster]
				)
		];

		var start_x = 150;
		var start_y = 150;
		for (entity in level.l_Entities.all_Mechanisms)
		{
			switch entity.f_Mechanism
			{
				case Start:
					start_x = entity.cx * sprite_size;
					start_y = entity.cy * sprite_size;
				case _:
					// case End:
					// case Door:
			}
		}

		for (entity in level.l_Entities.all_Pickups) {}

		hero = new Magician(core, start_x, start_y, sprite_size, sprites);

		var level_edge_right = level.l_Tiles.pxWid * scale;
		var level_edge_floor = level.l_Tiles.pxHei * scale;

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

		core.window.onMouseDown.add((x, y, button) -> if (button == MouseButton.LEFT)
		{
			x = (x - core.screen.display.xOffset) / core.screen.peote_view.zoom;
			y = (y - core.screen.display.yOffset) / core.screen.peote_view.zoom;
			// particles.emit(x, y);
			hero.cast_spell(x > hero.movement.position_x ? 1 : -1);
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
		hero.update_(
			elapsed_seconds,
			enemies,
			(x, y) ->
			{
				trace('$x, $y');
				particles.emit(x, y);
			},
			(grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
		);

		var monster_index = enemies.length;
		while (monster_index-- > 0)
		{
			var monster = enemies[monster_index];

			monster.update(elapsed_seconds, (grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y));
			if (!monster.is_expired)
			{
				if (monster.health > 0)
				{
					var x_grid_distance = Math.abs(hero.movement.column - monster.movement.column);
					var y_grid_distance = Math.abs(hero.movement.row - monster.movement.row);
					// fast distance check - is distance close enough to be seen?
					final sight_grid_limit = 3;
					var do_line_of_sight_check = x_grid_distance <= sight_grid_limit && y_grid_distance <= sight_grid_limit;
					if (do_line_of_sight_check)
					{
						var is_hero_in_sight = !is_line_blocked(
							hero.movement.column,
							hero.movement.row,
							monster.movement.column,
							monster.movement.row,
							(grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
						);
						// monster.sprite.tint.a = 0xff;
						if (is_hero_in_sight)
						{
							// monster.sprite.tint.a = 0x40;
							var angle = Math.atan2(hero.movement.position_y - monster.movement.position_y,
								hero.movement.position_x - monster.movement.position_x);
							monster.move_towards_angle(angle);
						}
					}
				}
				var is_overlapping_hero = hero.movement.column == monster.movement.column && hero.movement.row == monster.movement.row;

				if (is_overlapping_hero)
				{
					if (monster.health <= 0)
					{
						trace('pick up spell!');
						hero.inventory.make_available(monster.config.drop);
						monster.is_expired = true;
						monster.sprite.tint.a = 0;
						enemies.remove(monster);
					}
					else
					{
						hero.damage(1); // todo - proper damage
					}
				}
			}
		}

		particles.update(elapsed_seconds);

		var target_width_offset = (8 / 2);
		var target_height_offset = (8 / 2);
		var target_left = hero.movement.position_x - target_width_offset;
		var target_right = hero.movement.position_x + target_width_offset;
		var target_ceiling = hero.movement.position_y - target_height_offset;
		var target_floor = hero.movement.position_y + target_height_offset;
		camera.follow_target(target_left, target_right, target_ceiling, target_floor);
	}

	override function draw()
	{
		hero.draw();
		for (enemy in enemies)
		{
			enemy.draw();
		}
		sprites.update_all();
		camera.draw();
	}

	override function clean_up()
	{
		sprites.clear();
		blanks.clear();
	}
}
