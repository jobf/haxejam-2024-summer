package game.scenes;

import game.Core;
import game.Inventory;
import game.actor.*;
import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;

using lib.peote.TextureTools;

class TestSpellInventory extends GameScene
{
	var inventory: Inventory;
	var sprites: Sprites;
	var hero: Magician;

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
		var sprite_asset = Assets.getImage("assets/sprites-16.png");
		var sprite_texture = sprite_asset.tilesheet_from_image(tile_size, tile_size);
		sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"sprites",
			sprite_size,
			sprite_size
		);

		hero = new Magician(200, 200, sprite_size, sprites);

		inventory = new Inventory(core);

		inventory.make_available(PUNCH);
		inventory.make_available(FIREBALL);
		inventory.make_available(BONESPEAR);
		inventory.activate(PUNCH);

		controller.a.on_press = () -> inventory.toggle_visibility();
	}

	override function update(elapsed_seconds: Float)
	{
		hero.update(elapsed_seconds, (grid_x, grid_y) -> false);
	}

	override function draw()
	{
		hero.draw();
	}
}
