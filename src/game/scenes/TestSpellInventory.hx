package game.scenes;

import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import game.Core;
import game.Inventory;
import game.actor.*;

using lib.peote.TextureTools;

class TestSpellInventory extends GameScene
{
	var inventory: Inventory;

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
		inventory = new Inventory(core);

		inventory.make_available(PUNCH);
		inventory.make_available(FIREBALL);
		inventory.make_available(BONESPEAR);
		inventory.activate(PUNCH);
	}

	override function update(elapsed_seconds: Float) {}

	override function draw() {}
}
