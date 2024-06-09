package lib.peote;

import haxe.io.UInt8Array;
import lime.graphics.Image;
import peote.view.Display;
import peote.view.PeoteView;
import peote.view.Texture;

class TextureTools
{
	public static function tilesheet_from_image(image: Image, tile_width: Int, tile_height: Int): Texture
	{
		var texture = new Texture(image.width, image.height);
		texture.setData(image);
		texture.tilesX = Std.int(image.width / tile_width);
		texture.tilesY = Std.int(image.height / tile_height);
		return texture;
	}

	public static function read_pixels(display: Display): UInt8Array
	{
		var texture = new Texture(display.width, display.height);
		display.peoteView.setFramebuffer(display, texture);
		display.peoteView.renderToTexture(display);
		return texture.readPixelsUInt8(0, 0, display.width, display.height);
	}
}

/** Display which is rendered to a Texture **/
class TextureDisplay
{
	public var display(default, null): Display;
	public var texture(default, null): Texture;

	public function new(peote_view: PeoteView, width: Int, height: Int)
	{
		display = new Display(0, 0, width, height);
		peote_view.addFramebufferDisplay(display);
		texture = new Texture(width, height);
		display.setFramebuffer(texture, peote_view);
	}
}
