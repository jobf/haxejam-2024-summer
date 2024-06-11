package game.scenes;

import lib.peote.Elements;
import lib.pure.Calculate;
import lime.ui.MouseButton;
import lime.utils.Assets;
import game.Core;
import game.actor.*;

using lib.peote.TextureTools;

class TestParticles extends GameScene
{
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
		particles = new BlanksParticles(core);
		core.window.onMouseDown.add((x, y, button) -> particles.emit(x / core.screen.peote_view.zoom, y / core.screen.peote_view.zoom));
	}

	override function update(elapsed_seconds: Float)
	{
		particles.update(elapsed_seconds);
	}
}
