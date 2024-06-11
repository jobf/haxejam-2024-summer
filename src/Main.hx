import haxe.CallStack;
import haxe.Log;
import game.Core;
import game.Screen;
import game.scenes.*;
import lime.app.Application;
import lime.ui.KeyCode;
import peote.ui.PeoteUIDisplay;
import peote.view.PeoteView;

class Main extends Application
{
	var peote_view: PeoteView;
	var is_ready: Bool;

	var core: Core;
	var last_trace: Dynamic;

	override function onWindowCreate(): Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					is_ready = false;

					var background_color = 0xf000f0ff;
					peote_view = new PeoteView(window, background_color);
				} catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("We need OpenGL!");
		}
		var trace_original = Log.trace;
		Log.trace = (v, ?infos) ->
		{
			if (last_trace != v)
			{
				trace_original(v, infos);
				last_trace = v;
			}
		}
	}

	override function onPreloadComplete(): Void
	{
		PeoteUIDisplay.registerEvents(window);

		var res_width = 960;
		var res_height = 540;

		this.core = new Core(
			window,
			res_width,
			res_height,
			core -> new TestCombat(core),
			// core -> new TestEnemy(core),
			// core -> new TestHeroControls(core)
		);

		is_ready = true;
	}

	override function update(elapsed_ms: Int): Void
	{
		if (is_ready)
		{
			core.update(elapsed_ms / 1000);
		}
	}

	override function onKeyDown(keyCode: lime.ui.KeyCode, modifier: lime.ui.KeyModifier): Void
	{
		if (!is_ready)
			return;

		#if !web
		if (keyCode == ESCAPE)
		{
			window.close();
		}
		if (keyCode == 0)
		{
			window.resize(window.width * 2, window.height * 2);
		}
		if (keyCode == 9)
		{
			window.resize(Std.int(window.width / 2), Std.int(window.height / 2));
		}
		#end
	}
}
