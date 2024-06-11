package game.scenes;

import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import game.Core;
import game.actor.*;

using lib.peote.TextureTools;

class TestEnemy extends GameScene
{
	var sprites: Sprites;
	var enemy: Enemy;

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
		sprites = new Sprites(
			core.screen.display,
			sprite_texture,
			"sprites",
			sprite_size,
			sprite_size
		);
		enemy = new Enemy(100, 100, sprites {
			collision_radius: 5,
			animation_tile_indexes: [67, 68]
		});
	}

	override function update(elapsed_seconds: Float)
	{
		enemy.update(elapsed_seconds);
	}

	override function draw()
	{
		enemy.draw();
		sprites.update_all();
	}
}
