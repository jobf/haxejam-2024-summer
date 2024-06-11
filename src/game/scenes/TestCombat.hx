package game.scenes;

import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import game.Core;
import game.actor.*;

using lib.peote.TextureTools;

class TestCombat extends GameScene
{
	var sprites: Sprites;
	var hero: Magician;
	var enemies: Array<Enemy>;
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
		var template_asset = Assets.getImage("assets/sprites-16.png");
		var tile_size = 16;
		var sprite_texture = template_asset.tilesheet_from_image(tile_size, tile_size);
		var scale = 4;
		var sprite_size = tile_size * scale;
		particles = new BlanksParticles(core);
		sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"sprites",
			sprite_size,
			sprite_size
		);
		hero = new Magician(100, 100, sprites);

		var positions: Array<Array<Float>> = [[300, 300], [240, 30], [40, 400]];
		enemies = [
			for (pos in positions)
				new Enemy(pos[0], pos[1], sprites, {
					collision_radius: 16,
					animation_tile_indexes: [67, 68]
				})
		];

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

		core.window.onMouseDown.add((x, y, button) -> if (button == MouseButton.LEFT)
		{
			x = x - core.screen.display.xOffset;
			hero.cast_spell(x / core.screen.peote_view.zoom > hero.movement.position_x ? 1 : -1);
		});

		core.window.onMouseMove.add((x, y) ->
		{
			x = x - core.screen.display.xOffset;
			y = y - core.screen.display.yOffset;
			hero.scroll_follow_mouse(x / core.screen.peote_view.zoom, y / core.screen.peote_view.zoom);
		});
	}

	override function update(elapsed_seconds: Float)
	{
		hero.update_(
			elapsed_seconds,
			enemies,
			(x, y) -> particles.emit(x, y)
		);
		for (enemy in enemies)
		{
			enemy.update(elapsed_seconds);
		}
		particles.update(elapsed_seconds);
	}

	override function draw()
	{
		hero.draw();
		for (enemy in enemies)
		{
			enemy.draw();
		}
		sprites.update_all();
	}
}
