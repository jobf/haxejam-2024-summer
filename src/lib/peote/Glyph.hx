package lib.peote;

import lime.utils.Assets;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Program;
import peote.view.Texture;
import lib.peote.Elements;

using thx.Strings;

@:publicFields
class Glyphs
{
	var font: FontModel;
	var char_map: Map<Int, Int>;
	var buffer: Buffer<Tile>;
	var program: Program;
	var texture: Texture;
	var texture_name: String;

	public function new(display: Display, font: FontModel)
	{
		this.font = font;
		char_map = [];
		for (i in 0...font.char_map.length)
		{
			char_map.set(font.char_map.charCodeAt(i), i);
		}

		buffer = new Buffer<Tile>(font.element_count);
		program = new Program(buffer);
		program.blendEnabled = true;
		program.addToDisplay(display);

		var image = Assets.getImage(font.tile_asset_path);
		texture = new Texture(image.width, image.height);
		texture.tilesX = Std.int(image.width / font.tile_width);
		texture.tilesY = Std.int(image.height / font.tile_height);
		texture.setData(image, 0);
		texture_name = StringTools.replace(
			font.tile_asset_path,
			"/",
			"_"
		);
		texture_name = StringTools.replace(texture_name, "-", "_");
		texture_name = StringTools.replace(texture_name, ".", "_");
		program.addTexture(texture, texture_name);
	}

	public function make_line(x: Float, y: Float, text: String, tint: Int): GlyphLine
	{
		return {
			text: text,
			glyphs: this,
			tiles: [
				for (index in 0...text.length)
					buffer_tile(
						x,
						y,
						index,
						char_map[text.charCodeAt(index)],
						tint
					)
			]
		};
	}

	public function buffer_tile(line_x: Float, line_y: Float, index: Int, char_code: Int, tint: Color): Tile
	{
		var tile = new Tile(
			Std.int((index * font.element_width) + line_x),
			line_y,
			font.tile_width,
			font.tile_height,
			char_code,
			tint
		);

		buffer.addElement(tile);

		return tile;
	}

	public function update()
	{
		buffer.update();
	}

	inline public function char_tile_index(char_code: Int): Int
	{
		return char_map[char_code];
	}

	public function update_tile(tile: Tile)
	{
		buffer.updateElement(tile);
	}

	public function change_tint(tiles: Array<Tile>, tint: Int)
	{
		for (tile in tiles)
		{
			tile.tint = tint;
		}
		buffer.update();
	}

	public function clear()
	{
		buffer.clear();
	}
}

@:structInit
@:publicFields
class GlyphLine
{
	private var glyphs: Glyphs;
	var tiles: Array<Tile>;
	var text: String;
	var width(get, never): Int;
	var height(get, never): Int;

	function move(x: Int, y: Int)
	{
		var width = tiles[0].w;
		for (i => tile in tiles)
		{
			tile.x = x + (width * i);
			tile.y = y;
			glyphs.update_tile(tile);
		}
	}

	public function change_text(text: String)
	{
		this.text = text;
		var line_x = tiles[0].x;
		var line_y = tiles[0].y;
		var tint = tiles[0].tint;

		if (tiles.length > text.length)
		{
			for (tile in tiles)
			{
				// glyphs.char_map[text.charCodeAt(index)],
				tile.tile_index = glyphs.char_tile_index(30);
				glyphs.update_tile(tile);
			}
		}
		for (i in 0...text.length)
		{
			if (i > tiles.length - 1)
			{
				tiles.push(glyphs.buffer_tile(
					line_x,
					line_y,
					i,
					glyphs.char_tile_index(text.charCodeAt(i)),
					tint
				));
			}
			else
			{
				tiles[i].tile_index = glyphs.char_tile_index(text.charCodeAt(i));
				glyphs.update_tile(tiles[i]);
			}
		}
	}

	public function change_tint(tint: Int)
	{
		glyphs.change_tint(tiles, tint);
	}

	function get_width(): Int
	{
		if (tiles.length > 0)
		{
			return tiles.length * tiles[0].w;
		}
		return 0;
	}

	function get_height(): Int
	{
		if (tiles.length > 0)
		{
			return tiles.length * tiles[0].h;
		}
		return 0;
	}

	public function center_on(x: Float, y: Float)
	{
		move(Std.int(x - width / 2), Std.int(y));
	}

	public function change_alpha(a: Int)
	{
		var tint = tiles[0].tint;
		tint.a = a;
		change_tint(tint);
	}
}

class Pager
{
	var pages: Array<Array<String>>;
	var glyphs: Glyphs;
	var page_index: Int;
	var columns: Int;
	var rows: Int;
	var font_model: FontModel;
	var line_height: Int;
	var lines: Array<GlyphLine>;

	public function new(sections: Array<String>, display: Display, font_model: FontModel, width_px: Float, height_px: Float, line_height: Int)
	{
		this.pages = [];
		this.glyphs = new Glyphs(display, font_model);
		this.font_model = font_model;
		columns = Std.int(width_px / font_model.element_width);
		rows = Std.int(height_px / font_model.element_height);
		this.line_height = line_height;
		page_index = 0;
		for (section in sections)
		{
			var page = [];
			var is_page_pushed = false;
			for (line in section.wrapColumns(columns).split('\n'))
			{
				page.push(line);
				if (page.length == rows)
				{
					pages.push(page);
					is_page_pushed = true;
					page = [];
				}
			}
			if (!is_page_pushed)
			{
				pages.push(page);
			}
		}

		lines = [
			for (n => text in pages[page_index])
			{
				// trace(text);
				glyphs.make_line(
					0,
					n * font_model.element_height + 2,
					text,
					0xffffffff
				);
			}
		];
	}

	inline public function is_on_last_page(): Bool
	{
		return page_index >= pages.length - 1;
	}

	public function show_next_page()
	{
		if (!is_on_last_page())
		{
			page_index++;
			for (n => text in pages[page_index])
			{
				if (n < lines.length)
				{
					lines[n].change_text(text);
				}
				else
				{
					lines.push(glyphs.make_line(
						0,
						n * font_model.element_height + 2,
						text,
						0xffffffff
					));
				}
			}
		}
	}

	public function clear()
	{
		glyphs.clear();
	}
}

@:structInit
@:publicFields
class FontModel
{
	var tile_width: Int;
	var tile_height: Int;
	var tile_asset_path: String;
	var element_width: Int;
	var element_height: Int;
	var element_count: Int = 1024;
	var char_map: String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^`£abcdefghijklmnopqrstuvwxyz{|}~";
}

function ttf_to_png(ttf_path: String, point_size: Int, png_path: String)
{
	var char_map: String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^`£abcdefghijklmnopqrstuvwxyz{|}~";

	var args: Array<String> = [
		'-font $ttf_path',
		'-pointsize $point_size',
		'-background none',
		'label:@$char_map',
		png_path
	];
}
