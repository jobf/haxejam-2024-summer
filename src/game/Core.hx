package game;

import game.HudMenu;
import lib.input2action.Controller;
import lib.lime.Audio;
import lib.pure.SceneBase;
import lime.ui.MouseButton;
import lime.ui.Window;
import peote.view.PeoteView;

@:publicFields
class Core
{
	var window: Window;
	var scene: SceneBase<Core>;
	var is_paused: Bool;
	var screen: Screen;
	var input: Input;
	var sound: SoundManager;

	function new(window: Window, res_width: Int, res_height: Int, scene_constructor: Core -> SceneBase<Core>)
	{
		this.window = window;
		var peote_view = new PeoteView(window);
		screen = new Screen(peote_view, res_width, res_height);
		input = new Input(window);
		window.onRenderContextLost.add(() ->
		{
			trace('onRenderContextLost');
			pause();
		});
		window.onRenderContextRestored.add(context ->
		{
			trace('onRenderContextRestored');
			unpause();
		});
		window.onFocusOut.add(() ->
		{
			trace('onFocusOut');
			pause();
		});
		window.onFocusIn.add(() ->
		{
			trace('onFocusIn');
			unpause();
		});
		window.onMouseDown.add((f1, f2, button) ->
		{
			if (button == MouseButton.RIGHT)
			{
				pause();
			}
			if (button == MouseButton.LEFT)
			{
				unpause();
			}
		});

		sound = new SoundManager();
		sound.load_sound_assets([]);
		
		var fixed_steps_per_second = 30;

		#if !web
		window.onKeyDown.add((code, modifier) ->
		{
			if (code == ESCAPE)
			{
				window.close();
			}
		});
		#end

		scene_begin(scene_constructor);
	}

	function update(elapsed_seconds: Float)
	{
		if (!is_paused)
		{
			slide.Slide.step(elapsed_seconds);
			scene.update(elapsed_seconds);
			scene.draw();
			screen.update();
		}
	}

	function pause()
	{
		is_paused = true;
	}

	function unpause()
	{
		is_paused = false;
	}

	private function scene_begin(scene_constructor: Core -> SceneBase<Core>)
	{
		scene = scene_constructor(this);

		scene.begin();
	}

	private function scene_clean_up()
	{
		if (scene != null)
		{
			scene.clean_up();
		}
	}

	function scene_change(scene_constructor: Core -> SceneBase<Core>)
	{
		scene_clean_up();

		scene_begin(scene_constructor);
	}

	function scene_reset()
	{
		if (scene != null)
		{
			scene.clean_up();
			scene.begin();
			input.reset();
			is_paused = false;
		}
	}
}

class GameScene extends SceneBase<Core>
{
	var controller: ControllerActions;
	var menu_config: MenuConfig;
	var menu: HudMenu;

	public function new(core: Core, menu_config: MenuConfig)
	{
		super(core);

		this.menu_config = menu_config;
		controller = {
			select: {
				on_press: () ->
				{
					if (!menu.is_open)
					{
						menu_open();
					}
					else
					{
						menu_close();
					}
				},
			}
		}
	}

	function menu_open()
	{
		trace('core menu open');
		menu.open(null);
		core.pause();
		menu.controller.select.on_press = () -> menu_close();
		core.input.change_target(menu.controller);
	}

	function menu_close()
	{
		trace('core menu close');
		menu.close();
		core.unpause();
		core.input.change_target(controller);
	}

	public function begin()
	{
		menu = new HudMenu(core, menu_config);
		menu_close();
	}

	public function update(elapsed_seconds: Float) {}

	public function draw() {}

	public function clean_up()
	{
		menu.close();
		menu.dispose();
		menu = null;
	}
}

@:enum
abstract SoundKey(Int) from Int to Int
{
	// var NEW = 0;
}