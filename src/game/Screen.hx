package game;

import lib.pure.Rectangle;
import peote.ui.PeoteUIDisplay;
import peote.view.Display;
import peote.view.PeoteView;

@:publicFields
class Screen
{
	var peote_view: PeoteView;
	var res_width: Int;
	var res_height: Int;
	var window_width: Int;
	var window_height: Int;
	var display_level_tiles: Display;
	var display: Display;
	var display_hud: PeoteUIDisplay;
	var display_menu: PeoteUIDisplay;
	var res_limits: Rectangle;
	var view_x: Float = 0;
	var view_y: Float = 0;

	function new(peote_view: PeoteView, res_width: Int, res_height: Int)
	{
		this.peote_view = peote_view;
		this.res_width = res_width;
		this.res_height = res_height;
		this.res_limits = {
			x: 0,
			y: 0,
			width: res_width,
			height: res_height
		}
		this.window_width = peote_view.window.width;
		this.window_height = peote_view.window.height;
		display_level_tiles = new Display(0, 0, res_width, res_height, Colors.TRANSPARENT);
		display = new Display(0, 0, res_width, res_height, Colors.TRANSPARENT);
		display_hud = new PeoteUIDisplay(0, 0, res_width, res_height, Colors.TRANSPARENT);
		display_menu = new PeoteUIDisplay(0, 0, res_width, res_height, Colors.MAROON);
		peote_view.addDisplay(display_level_tiles);
		peote_view.addDisplay(display);
		peote_view.addDisplay(display_hud);
		peote_view.addDisplay(display_menu);
		peote_view.window.onResize.add((width, height) ->
		{
			this.window_width = width;
			this.window_height = height;
			fit_to_window();
		});
		fit_to_window();
		peote_view.start();
	}

	inline function display_menu_hide()
	{
		display_menu.hide();
	}

	inline function display_menu_show()
	{
		display_menu.show();
	}

	function fit_to_window()
	{
		var scale = 1.0;

		if (res_height < res_width)
		{
			// use height to determine scale when height is smaller edge
			scale = window_height / res_height;
		}
		else
		{
			// use width to determine scale when width is smaller edge
			scale = window_width / res_width;
		}

		// keep scale is noit less than 1
		if (scale < 1)
		{
			scale = 1;
		}

		// ensure up-scaling is an even number
		if (scale > 2 && scale % 2 != 0)
		{
			scale -= 1;
		}

		// scale all of peote-view (then every display is scaled together)
		peote_view.zoom = scale;

		// offset the view display to keep it in the center of the window
		view_x = ((peote_view.width / scale) / 2) - (res_width / 2);
		view_y = ((peote_view.height / scale) / 2) - (res_height / 2);
		// display.x = view_x;
		// display.y = view_y;
		// display_level_tiles.x = view_x;
		// display_level_tiles.y = view_y;
	}

	public function update()
	{
		var x = Std.int(view_x);
		var y = Std.int(view_y);
		display_level_tiles.x = x;
		display_level_tiles.y = y;

		display.x = x;
		display.y = y;

		// display_hud.x = x;
		// display_hud.y = y;
	}
}
