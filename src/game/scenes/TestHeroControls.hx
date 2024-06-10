package game.scenes;

import lib.peote.Elements;
import lime.utils.Assets;
import game.Actor.Magician;
import game.Core;

using lib.peote.TextureTools;

class TestHeroControls extends GameScene {
	var sprites:Sprites;
	var hero:Magician;

	public function new(core:Core) {
		super(core, {
			introduction: ["testing"],
			items: [
				{
					item_type: ACTION,
					label: "reset scene",
					action: () -> core.scene_reset(),
					is_valid: () -> true,
					description: "WORLD",
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

	override function begin() {
		super.begin();
		var template_asset = Assets.getImage("assets/sprites-16.png");
		var tile_size = 16;
		var sprite_texture = template_asset.tilesheet_from_image(tile_size, tile_size);
		var scale = 4;
		var tile_size = tile_size * scale;
		sprites = new Sprites(core.screen.display, sprite_texture, "sprites", tile_size, tile_size);
		hero = new Magician(100, 100, sprites);
		init_controller();
	}

	function init_controller() {
		controller.left = {
			on_press: () -> {
				hero.move_in_direction_x(-1);
			},
			on_release: () -> {
				hero.stop_x();
			}
		}

		controller.right = {
			on_press: () -> {
				hero.move_in_direction_x(1);
			},
			on_release: () -> {
				hero.stop_x();
			}
		}

		controller.up = {
			on_press: () -> {
				hero.move_in_direction_y(-1);
			},
			on_release: () -> {
				hero.stop_y();
			}
		}

		controller.down = {
			on_press: () -> {
				hero.move_in_direction_y(1);
			},
			on_release: () -> {
				hero.stop_y();
			}
		}
		controller.a = {
			on_press: () -> hero.dash()
		}

		controller.b = {
			on_press: () -> hero.cast_spell()
		}

		controller.start.on_press = () -> {}

		core.input.change_target(controller);
		draw();
	}

	override function update(elapsed_seconds:Float) {
		hero.update(elapsed_seconds);
	}

	override function draw() {
		hero.draw();
		sprites.update_all();
	}
}
