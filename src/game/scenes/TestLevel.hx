package game.scenes;

import lib.ldtk.TileMapping;
import lib.peote.Camera;
import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import peote.view.Color;
import game.Core;
import game.LdtkData;
import game.actor.*;

using lib.peote.TextureTools;

class TestLevel extends GameScene
{
	var blanks: Blanks;
	var tiles_level: Tiles;
	var sprites: Sprites;
	var hero: Magician;
	var level: LdtkData_Level;
	var camera: Camera;

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

		hero = new Magician(150, 150, sprite_size, sprites);

		var levels = new LdtkData();

		level = levels.all_worlds.Default.levels[0];

		var debug_level_collisions = false;
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
			for (tile in tile_stack)
			{
				var is_flipped_x = tile.flipBits == 1;
				tiles_level.make_aligned(column, row, sprite_size, tile.tileId, is_flipped_x);
			}
			// get the top tile of the stack only
			// var tile = tile_stack[tile_stack.length - 1];
			// var is_flipped_x = tile.flipBits == 1;
			// tiles_level.make_aligned(column, row, sprite_size, tile.tileId, is_flipped_x);
		});

		camera = new Camera([core.screen.display_level_tiles, core.screen.display], {
			view_width: core.screen.res_width,
			view_height: core.screen.res_height,
			boundary_left: 0,
			boundary_right: level.l_Tiles.pxWid * scale,
			boundary_ceiling: 0,
			boundary_floor: level.l_Tiles.pxHei * scale,
			zone_center_x: hero.movement.position_x,
			zone_center_y: hero.movement.position_y,
			zone_width: 128,
			zone_height: 128
		});

		camera.center_on(hero.movement.position_x, hero.movement.position_y);
		camera.toggle_debug();

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

		core.input.change_target(controller);

		core.window.onMouseDown.add((x, y,
				button) -> if (button == MouseButton.LEFT) hero.cast_spell(x / core.screen.peote_view.zoom > hero.movement.position_x ? 1 : -1));
		core.window.onMouseMove.add((x, y) ->
		{
			hero.scroll_follow_mouse(x / core.screen.peote_view.zoom, y / core.screen.peote_view.zoom);
		});
	}

	override function update(elapsed_seconds: Float)
	{
		hero.update_(
			elapsed_seconds,
			[],
			(x, y) -> trace('hit $x $y'),
			(grid_x, grid_y) -> level.l_Collision.hasValue(grid_x, grid_y)
		);

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
		sprites.update_all();
		camera.draw();
	}
}
