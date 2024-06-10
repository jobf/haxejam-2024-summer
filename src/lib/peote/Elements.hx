package lib.peote;

import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;
import peote.view.Texture;

class Blank implements Element {
	/**
		position on x axis
	**/
	@posX public var x:Float;

	/**
		position on y axis
	**/
	@posY public var y:Float;

	/**
		width in pixels
	**/
	@varying @sizeX public var width:Int;

	/**
		height in pixels
	**/
	@varying @sizeY public var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivot_x") var pivot_x:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivot_y") var pivot_y:Float = 0.0;

	/**
		rotation in degrees
	**/
	@rotation public var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color;

	var OPTIONS = {blend: true};

	public function new(x:Float, y:Float, width:Float, height:Float, tint:Color = 0xffffffFF, is_center_pivot:Bool = false) {
		this.x = Std.int(x);
		this.y = Std.int(y);

		this.width = Std.int(width);
		this.height = Std.int(height);

		this.tint = tint;

		if (is_center_pivot) {
			this.pivot_x = 0.5;
			this.pivot_y = 0.5;
		}
	}
}

@:publicFields
class Blanks {
	private var buffer:Buffer<Blank>;
	private var program:Program;

	function new(display:Display, buffer_size:Int = 256) {
		buffer = new Buffer<Blank>(buffer_size, buffer_size, true);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);
	}

	function make(x:Float, y:Float, size:Float, is_center_pivot:Bool = true, tint:Int = 0xf0f0f0ff):Blank {
		var element = new Blank(Std.int(x), Std.int(y), Std.int(size), Std.int(size), tint, is_center_pivot);
		buffer.addElement(element);
		return element;
	}

	function make_aligned(column:Float, row:Float, align_px:Float, width_px:Float, height_px:Float, tint:Int):Blank {
		var element = new Blank(Std.int(column * align_px), Std.int(row * align_px), Std.int(width_px), Std.int(height_px), tint, false);

		buffer.addElement(element);
		return element;
	}

	function update_element(element:Blank) {
		buffer.updateElement(element);
	}

	function update_all() {
		buffer.update();
	}

	public function set_fragment_shader(fragment:String, color_formula:String) {
		program.injectIntoFragmentShader(fragment);
		program.setColorFormula(color_formula);
	}

	public function clear() {
		buffer.clear();
	}
}

@:publicFields
class Tiles {
	private var buffer:Buffer<Tile>;
	private var program:Program;
	var tile_size_px:Int;
	var texture:Texture;
	var total:Int = 0;

	function new(display:Display, texture:Texture, unique_id:String, tile_size_px:Int, buffer_page_size:Int = 256) {
		this.texture = texture;
		this.tile_size_px = tile_size_px;

		buffer = new Buffer<Tile>(buffer_page_size, buffer_page_size, true);

		program = new Program(buffer);
		program.blendEnabled = true;
		program.snapToPixel(1);
		program.addToDisplay(display);
		program.addTexture(texture, unique_id);
		display.addProgram(program);
	}

	function make(x:Float, y:Float, width:Float, height:Float, tile_index:Int, is_flipped_x:Bool = false):Tile {
		var element = new Tile(Std.int(x), Std.int(y), Std.int(width), Std.int(height), tile_index, 0xffffffff, is_flipped_x);

		buffer.addElement(element);
		total++;
		return element;
	}

	function make_aligned(column:Int, row:Int, align_px:Int, tile_index:Int, is_flipped_x:Bool):Tile {
		return make(column * align_px, row * align_px, tile_size_px, tile_size_px, tile_index, is_flipped_x);
	}

	function update_element(element:Tile) {
		buffer.updateElement(element);
	}

	function update_all() {
		buffer.update();
	}

	public function clear() {
		buffer.clear();
	}
}

class Tile implements Element {
	/**
		pixel position of the left edge
	**/
	@posX public var x:Float;

	/**
		pixel position of the top edge
	**/
	@posY public var y:Float;

	/**
		pixel width
	**/
	@varying @sizeX public var w:Int;

	/**
		pixel height
	**/
	@varying @sizeY public var h:Int;

	/**
		refers to the index of the tile within a large texture that has been partitioned
	**/
	@texTile() public var tile_index:Int;

	/**
		a color which tints the tile, for easy tinting the raw tile data to be tinted should be white
	**/
	@color public var tint:Color;

	public function new(x:Float, y:Float, width:Int, height:Int, tile_index:Int, tint:Color = 0xffffffff, flip_x:Bool = false) {
		this.x = x;
		this.y = y;
		this.w = width;
		this.h = height;
		if (flip_x) {
			this.w = -width;
			this.x += width;
		}
		this.tile_index = tile_index;
		this.tint = tint;
	}
}

class Sprite implements Element {
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x:Float;
	@posY public var y:Float;

	// offset center position
	@pivotX @formula("(width * facing_x) * offset_x + px_offset") public var px_offset:Float = 0.0;
	@pivotY @formula("height * offset_y + py_offset") public var py_offset:Float = 0.0;

	@custom public var offset_x:Float = 0.5;
	@custom public var offset_y:Float = 0.5;

	@sizeX @varying @formula("width * facing_x") var x_size:Float;

	@varying @sizeY public var height:Float;

	@custom @varying public var width:Float;
	@custom @varying public var facing_x:Int = 1;

	@rotation public var angle:Float = 0.0;
	// RGBA
	@color public var tint:Color;

	@texTile() public var tile_index:Int;

	var OPTIONS = {blend: true};

	@zIndex public var z:Int = 0;

	public function new(x:Int, y:Int, width:Int, height:Int, tile_index:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.tile_index = tile_index;
		this.tint = 0xffffffFF;
	}
}

/**
	Designed for use with Textures that are a "sprite sheet" of equally sized square sprites
**/
@:publicFields
class Sprites {
	private var buffer:Buffer<Sprite>;
	private var program:Program;
	var tile_size_px:Int;
	var texture:Texture;
	var total:Int = 0;

	function new(display:Display, texture:Texture, unique_id:String, tile_size_px:Int, buffer_page_size:Int = 256) {
		this.tile_size_px = tile_size_px;

		buffer = new Buffer<Sprite>(buffer_page_size, buffer_page_size, true);

		program = new Program(buffer);
		program.blendEnabled = true;
		program.addToDisplay(display);
		program.addTexture(texture, unique_id);
		// program.snapToPixel(1);
		display.addProgram(program);
	}

	function make(x:Float, y:Float, tile_index:Int, is_center_pivot:Bool = true):Sprite {
		var element = new Sprite(Std.int(x), Std.int(y), tile_size_px, tile_size_px, tile_index);

		buffer.addElement(element);

		total++;

		return element;
	}

	function make_aligned(column:Int, row:Int, align_px:Int, tile_index:Int, is_center_pivot:Bool = true):Sprite {
		return make(column * align_px, row * align_px, tile_index, is_center_pivot);
	}

	function update_element(element:Sprite) {
		buffer.updateElement(element);
	}

	function update_all() {
		buffer.update();
	}

	public function clear() {
		buffer.clear();
	}

	public function remove(element:Sprite) {
		buffer.removeElement(element);
	}
}

@:publicFields
class Fill implements Element {
	/**
		position on x axis
	**/
	@posX var x:Float;

	/**
		position on y axis
	**/
	@posY var y:Float;

	/**
		width in pixels
	**/
	@sizeX var width:Int;

	/**
		height in pixels
	**/
	@sizeY var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivot_x") var pivot_x:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivot_y") var pivot_y:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color var tint:Color;

	var OPTIONS = {blend: true};

	/**
		index of tile in texture, relative to Texture tile configuration
	**/
	@varying @texTile() var tile_index:Int;

	/**
		rotation in degrees
	**/
	@rotation var angle:Float = 0.0;

	/**
		size of repeated tile on x axis
	**/
	@varying @custom @formula("width / tile_width") var tile_width:Float;

	/**
		size of repeated tile on y axis
	**/
	@varying @custom @formula("height / tile_height") var tile_height:Float;

	/**
		how fast the texture offset on x axis is scrolled (needs is_scrolling_enabled = true)
	**/
	@varying @custom var scroll_speed_x:Float = 0.0;

	/**
		how fast the texture offset on y axis is scrolled (needs is_scrolling_enabled = true)
	**/
	@varying @custom var scroll_speed_y:Float = 0.0;

	private function new(x:Int, y:Int, width:Int, height:Int, tile_index:Int, tile_width:Float, tint:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.tile_index = tile_index;
		this.tile_width = tile_width;
		this.tile_height = tile_width;
		this.tint = tint;
	}

	static function program_init(program:Program, ?display:Display = null, texture:Texture, texture_id:String, tile_columns:Int, tile_rows:Int,
			is_scrolling_enabled:Bool = false):Void {
		texture.tilesX = tile_columns;
		texture.tilesY = tile_rows;

		// var program = new Program(buffer);
		program.addTexture(texture, texture_id);

		if (is_scrolling_enabled) {
			program.injectIntoFragmentShader('
			vec2 scroll(vec2 pos, float move_x, float move_y)
			{
				pos.x = pos.x + (move_x * uTime);
				pos.y = pos.y + (move_y * uTime);
				return pos;
			}
			', true);

			program.setColorFormula('tint * getTextureColor( ${texture_id}_ID, fract(scroll(vTexCoord, scroll_speed_x, scroll_speed_y) * vec2(tile_width, tile_height)) )');
		} else {
			program.setColorFormula('tint * getTextureColor( ${texture_id}_ID, fract(vTexCoord * vec2(tile_width, tile_height)) )');
		}

		if (display != null) {
			display.addProgram(program);
		}

		// return program;
	}

	static function make(x:Float, y:Float, width:Float, height:Float, tile_index:Int, tile_width:Int, tint:Int, ?config:FillConfig = null):Fill {
		var element = new Fill(Std.int(x), Std.int(y), Std.int(width), Std.int(height), tile_index, tile_width, tint);

		if (config != null) {
			element.tile_height = config.tile_height ?? tile_width;
			element.scroll_speed_x = config.scroll_speed_x;
			element.scroll_speed_y = config.scroll_speed_y;

			if (config.mirror_element_h) {
				element.width = -element.width;
				element.x += element.width;
			}

			if (config.mirror_element_v) {
				element.height = -element.height;
				element.y += element.height;
			}

			if (config.mirror_x) {
				element.tile_width = -element.tile_width;
			}

			if (config.mirror_y) {
				element.tile_height = -element.tile_height;
			}
		}

		return element;
	}
}

@:publicFields
@:structInit
class FillConfig {
	var tile_height:Null<Int> = null;
	var mirror_x:Bool = false;
	var mirror_y:Bool = false;
	var mirror_element_h:Bool = false;
	var mirror_element_v:Bool = false;
	var scroll_speed_x:Float = 0.0;
	var scroll_speed_y:Float = 0.0;
}

@:publicFields
class Fills {
	private var buffer:Buffer<Fill>;
	private var program:Program;
	var tile_size_px:Int;
	var texture:Texture;
	var total:Int = 0;

	function new(display:Display, texture:Texture, unique_id:String, tile_size_px:Int, tiles_wide:Int, tiles_high:Int, buffer_page_size:Int = 256) {
		this.tile_size_px = tile_size_px;

		buffer = new Buffer<Fill>(buffer_page_size, buffer_page_size, true);

		program = new Program(buffer);
		Fill.program_init(program, display, texture, unique_id, tiles_wide, tiles_high, true);
		// program.blendEnabled = true;
		// program.addToDisplay(display);
		// program.addTexture(texture, unique_id);
		// program.snapToPixel(1);
		// display.addProgram(program);
	}

	function make(x:Float, y:Float, tile_index:Int, width:Null<Int> = null, height:Null<Int> = null, is_center_pivot:Bool = true, tint:Int = 0xFFFFFFFF):Fill {
		var w = width ?? tile_size_px;
		var h = height ?? tile_size_px;
		var element = Fill.make(x, y, w, h, tile_index, tile_size_px, tint);

		buffer.addElement(element);

		total++;

		return element;
	}

	function make_aligned(column:Int, row:Int, align_px:Int, tile_index:Int, is_center_pivot:Bool = true):Fill {
		return make(column * align_px, row * align_px, tile_index, is_center_pivot);
	}

	function update_element(element:Fill) {
		buffer.updateElement(element);
	}

	function update_all() {
		buffer.update();
	}

	public function clear() {
		buffer.clear();
	}
}
