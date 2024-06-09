package lib.peote;

import lib.peote.Elements;
import lib.pure.Calculate;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;

@:structInit
/**
	Configure Camera scroll boundaries and dead zone.
	All values relate to pixel positions in the world.
	Camera will not scroll outside boundaries.
	Camera will only scroll if target is outside dead zone.
**/
class ScrollConfig
{
	/** width of viewable area, e.g. the window**/
	public var view_width: Int;

	/** height of viewable area, e.g. the window**/
	public var view_height: Int;

	/**left side of view cannot be scrolled beyond this**/
	public var boundary_left: Int = 0;

	/**right side of view cannot be scrolled beyond this**/
	public var boundary_right: Int = 0;

	/**top of view cannot be scrolled beyond this**/
	public var boundary_ceiling: Int = 0;

	/**bottom of view cannot be scrolled beyond this**/
	public var boundary_floor: Int = 0;

	/**central position of dead zone x**/
	public var zone_center_x: Float = 0;

	/**central position of dead zone y**/
	public var zone_center_y: Float = 0;

	/**width of dead zone**/
	public var zone_width: Int = 0;

	/**width of dead zone**/
	public var zone_height: Int = 0;
}

/**
	Used to control display offsets to scroll the area is viewed;
**/
class Camera
{
	public var scroll(default, null): ScrollConfig;
	public var zoom(get, set): Float;

	/**the display to be offset**/
	var displays: Array<Display>;

	var view_center_x: Float;
	var view_center_y: Float;

	var zone_width_offset: Float;
	var zone_height_offset: Float;
	var zone_left: Float;
	var zone_ceiling: Float;
	var zone_right: Float;
	var zone_floor: Float;

	var debug: CameraDebug;
	var is_debug_visible: Bool = false;
	var offset_x: Int;
	var offset_y: Int;
	var previous_offset_x: Float;
	var previous_offset_y: Float;

	public function new(displays: Array<Display>, scrolling: ScrollConfig)
	{
		this.displays = displays;
		this.scroll = scrolling;
		debug = new CameraDebug(displays[displays.length - 1]);
		toggle_debug();
	}

	public function center_on(x: Float, y: Float)
	{
		scroll.zone_center_x = Std.int(x);
		scroll.zone_center_y = Std.int(y);

		center_camera_x(scroll.zone_center_x);
		center_camera_y(scroll.zone_center_y);

		if (is_debug_visible)
		{
			debug.update(scroll);
		}
	}

	var is_eased: Bool = true;
	var scroll_zone_center_previous_x: Float;
	var scroll_zone_center_previous_y: Float;

	public function follow_target(target_left: Float, target_right: Float, target_ceiling: Float, target_floor: Float)
	{
		previous_offset_x = offset_x;
		previous_offset_y = offset_y;
		scroll_zone_center_previous_x = scroll.zone_center_x;
		scroll_zone_center_previous_y = scroll.zone_center_y;
		/*
			update dead zone limits
		 */
		zone_width_offset = scroll.zone_width / 2;
		zone_height_offset = scroll.zone_height / 2;
		zone_left = scroll.zone_center_x - zone_width_offset;
		zone_ceiling = scroll.zone_center_y - zone_height_offset;
		zone_right = scroll.zone_center_x + zone_width_offset;
		zone_floor = scroll.zone_center_y + zone_height_offset;

		if (is_eased)
		{
			/* 
				update camera if target is outsize dead zone
			 */
			if (target_left <= zone_left)
			{
				var distance_to_point_target = Std.int((zone_left - target_left));
				scroll.zone_center_x -= distance_to_point_target;
				center_camera_x(scroll.zone_center_x);
			}
			if (target_ceiling <= zone_ceiling)
			{
				scroll.zone_center_y -= Std.int(zone_ceiling - target_ceiling);
				center_camera_y(scroll.zone_center_y);
			}
			if (target_right >= zone_right)
			{
				scroll.zone_center_x += Std.int(target_right - zone_right);
				center_camera_x(scroll.zone_center_x);
			}
			if (target_floor >= zone_floor)
			{
				scroll.zone_center_y += Std.int(target_floor - zone_floor);
				center_camera_y(scroll.zone_center_y);
			}
		}
		else
		{
			/* 
				update camera if target is outsize dead zone
			 */
			if (target_left <= zone_left)
			{
				scroll.zone_center_x -= Std.int(zone_left - target_left);
				center_camera_x(scroll.zone_center_x);
			}
			if (target_ceiling <= zone_ceiling)
			{
				scroll.zone_center_y -= Std.int(zone_ceiling - target_ceiling);
				center_camera_y(scroll.zone_center_y);
			}
			if (target_right >= zone_right)
			{
				scroll.zone_center_x += Std.int(target_right - zone_right);
				center_camera_x(scroll.zone_center_x);
			}
			if (target_floor >= zone_floor)
			{
				scroll.zone_center_y += Std.int(target_floor - zone_floor);
				center_camera_y(scroll.zone_center_y);
			}
		}

		/*
			update visible dead zone debugger
		 */
		if (is_debug_visible)
		{
			debug.update(scroll);
		}
	}

	var x_offset: Float = 0;
	var y_offset: Float = 0;

	public function draw(step_ratio: Float)
	{
		x_offset = Math.floor(lerp(previous_offset_x, offset_x, step_ratio));
		y_offset = Math.floor(lerp(previous_offset_y, offset_y, step_ratio));

		for (display in displays)
		{
			display.xOffset = x_offset;
			display.yOffset = y_offset;
		}
	}

	/**toggle visibility of dead zone debugger**/
	public function toggle_debug()
	{
		is_debug_visible = !is_debug_visible;
		debug.is_visible = is_debug_visible;
	}

	/**center the camera x axis on the target, will stay within scroll boundaries**/
	inline function center_camera_x(target: Float)
	{
		// determine view center
		view_center_x = (scroll.view_width / 2) / zoom;

		// keep within boundary left
		var x_scroll_min = view_center_x;
		if (target < x_scroll_min)
		{
			view_center_x -= (x_scroll_min - target);
		}

		// keep within boundary right
		var x_scroll_max = (scroll.boundary_right - view_center_x);
		if (target > x_scroll_max)
		{
			view_center_x += (target - x_scroll_max);
		}

		// update display offset to move the viewed area
		offset_x = -Std.int((target - view_center_x) * zoom);
		// display.xOffset = -Std.int((target - view_center_x) * zoom);
	}

	public function clear()
	{
		debug.clear();
	}

	/**center the camera y axis on the target, will stay within scroll boundaries**/
	inline function center_camera_y(target: Float)
	{
		// determine view center
		view_center_y = (scroll.view_height / 2) / zoom;

		// keep within boundary ceiling
		var y_scroll_min = view_center_y;
		if (target < y_scroll_min)
		{
			view_center_y -= (y_scroll_min - target);
		}

		// keep within boundary floor
		var y_scroll_max = (scroll.boundary_floor - view_center_y);
		if (target > y_scroll_max)
		{
			view_center_y += (target - y_scroll_max);
		}

		// update display offset to move the viewed area
		offset_y = -Std.int((target - view_center_y) * zoom);
		// display.yOffset = -Std.int((target - view_center_y) * zoom);
	}

	function get_zoom(): Float
	{
		return displays[0].zoom;
	}

	function set_zoom(value: Float): Float
	{
		for (display in displays)
		{
			display.zoom = value;
		}
		return displays[0].zoom;
	}
}

class CameraDebug
{
	var buffer: Buffer<Blank>;
	var program: Program;
	var zone_graphic: Blank;

	var color_visible: Int = 0x00e5ff20;
	var color_hidden: Int = 0x00000000;

	public function new(display: Display)
	{
		buffer = new Buffer<Blank>(1);
		program = new Program(buffer);
		program.addToDisplay(display);

		zone_graphic = new Blank(-10, -10, 1, 1, true);
		zone_graphic.tint = color_visible;
		buffer.addElement(zone_graphic);
	}

	inline public function update(scroll: ScrollConfig)
	{
		zone_graphic.x = scroll.zone_center_x;
		zone_graphic.width = scroll.zone_width;
		zone_graphic.y = scroll.zone_center_y;
		zone_graphic.height = scroll.zone_height;
		buffer.updateElement(zone_graphic);
	}

	public var is_visible(get, set): Bool;

	function get_is_visible(): Bool
	{
		return zone_graphic.tint == color_visible;
	}

	function set_is_visible(is_visible: Bool): Bool
	{
		zone_graphic.tint = is_visible ? color_visible : color_hidden;
		buffer.updateElement(zone_graphic);
		return is_visible;
	}

	public function clear()
	{
		buffer.clear();
	}
}
