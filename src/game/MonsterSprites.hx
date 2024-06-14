package game;

import lib.peote.Elements;
import lime.utils.Assets;
import game.Configurations;

using lib.peote.TextureTools;

@:publicFields
class MonsterSprites
{
	var sprites_16: Sprites;
	var sprites_32: Sprites;
	var sprites_64: Sprites;

	function new(core: Core, scale:Int) {
		sprites_16 = init_sprites(core, 16, 16 * scale);
		sprites_32 = init_sprites(core, 32, 32 * scale);
		sprites_64 = init_sprites(core, 64, 64 * scale);
	}

	private function init_sprites(core: Core, tile_size: Int, render_size: Int): Sprites
	{
		var sprite_asset = Assets.getImage('assets/sprites-$tile_size.png');
		var sprite_texture = sprite_asset.tilesheet_from_image(tile_size, tile_size);
		return new Sprites(
			core.screen.display,
			sprite_texture,
			'sprites_${tile_size}_${render_size}',
			render_size,
			render_size
		);
	}

	function draw()
	{
		sprites_16.update_all();
		sprites_32.update_all();
		sprites_64.update_all();
	}

	function get_sprites(tile_size:TileSize):Sprites
	{
		return switch tile_size
		{
			case _16: sprites_16;
			case _32: sprites_32;
			case _64: sprites_64;
		}
	}

	function clear()
	{
		sprites_16.clear();
		sprites_32.clear();
		sprites_64.clear();
	}
}
