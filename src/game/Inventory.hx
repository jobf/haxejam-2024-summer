package game;

import game.Configurations;
import lib.peote.Elements;
import lib.peote.Glyph;
import lime.utils.Assets;
import peote.ui.interactive.UIElement;

using lib.peote.TextureTools;

@:publicFields
class Inventory
{
	var glyphs: Glyphs;
	var tiles: Tiles;
	var button_slots: Array<SpellButton> = [];
	var active_slots: Array<SpellButton> = [];
	var core: Core;
	var blanks: Blanks;

	function new(core: Core)
	{
		this.core = core;
		blanks = new Blanks(core.screen.display_hud);
		var font: FontModel = {
			element_width: 16,
			element_height: 16,
			tile_width: 8,
			tile_height: 8,
			tile_asset_path: "assets/font-zx-origins_carton-8.png",
		}
		var tile_size: Int = 16;
		var button_tile_size = 6 * tile_size;
		var equipped_tile_size = 12 * tile_size;

		glyphs = new Glyphs(core.screen.display_hud, font);
		var sprite_asset = Assets.getImage("assets/sprites-16.png");
		var sprite_texture = sprite_asset.tilesheet_from_image(tile_size, tile_size);
		tiles = new Tiles(
			core.screen.display_hud,
			sprite_texture,
			"tiles",
			button_tile_size,
			button_tile_size
		);

		var slots_x = 20;
		var slots_y = 20;

		blanks.rect(
			10,
			10,
			core.screen.res_width - 20,
			core.screen.res_height - 20,
			0x000000ff
		);

		var gap = 20;
		for (r in 0...3)
		{
			for (c in 0...3)
			{
				var x = slots_x + ((button_tile_size + gap) * c);
				var y = slots_y + ((button_tile_size + gap) * r);
				var button = new SpellButton(
					x,
					y,
					button_tile_size,
					tiles.make(x, y, button_tile_size, button_tile_size, 31, false),
					Configurations.spells[EMPTY],
					activate
				);

				core.screen.display_hud.add(button);
				button_slots.push(button);
			}
		}

		var equipped_x = slots_x + (3 * (button_tile_size + gap)) + gap;
		var equipped_y = slots_y;
		for (r in 0...2)
		{
			var x = equipped_x;
			var y = equipped_y + ((equipped_tile_size + gap) * r);
			var button = new SpellButton(
				x,
				y,
				equipped_tile_size,
				tiles.make(
					x,
					y,
					equipped_tile_size,
					equipped_tile_size,
					31,
					false
				),
				Configurations.spells[EMPTY],
				clear
			);

			core.screen.display_hud.add(button);
			active_slots.push(button);
		}
	}

	public function toggle_visibility()
	{
		if (core.screen.display_hud.isVisible)
		{
			core.screen.display_hud.hide();
		}
		else
		{
			core.screen.display_hud.show();
		}
	}

	function make_available(key: SpellType)
	{
		var available = button_slots.filter(button -> key == button.config.key);
		if (available.length == 0)
		{
			for (button in button_slots)
			{
				if (button.config.key == EMPTY)
				{
					button.change_spell(key);
					tiles.update_element(button.tile);
					break;
				}
			}
		}
	}

	function activate(key: SpellType)
	{
		var already_set = active_slots.filter(button -> key == button.config.key);
		if (already_set.length == 0)
		{
			for (button in active_slots)
			{
				if (button.config.key == EMPTY)
				{
					button.change_spell(key);
					tiles.update_element(button.tile);
					break;
				}
			}
		}
	}

	function clear(key: SpellType)
	{
		for (button in active_slots)
		{
			if (button.config.key == key)
			{
				button.change_spell(EMPTY);
				tiles.update_element(button.tile);
				break;
			}
		}
	}
}

@:publicFields
class SpellButton extends UIElement
{
	var config: SpellConfig;
	var tile: Tile;

	function new(x: Float, y: Float, size: Float, tile: Tile, config: SpellConfig, onClick: (key: SpellType) -> Void)
	{
		super(Std.int(x), Std.int(y), Std.int(size), Std.int(size));

		this.config = config;
		this.tile = tile;

		onPointerDown = (element, pointer_event) ->
		{
			if (this.config.key != EMPTY)
			{
				onClick(this.config.key);
			}
			else
			{
				trace(0);
			}
		};
		onPointerUp = (element, pointer_event) -> trace('release');
		onPointerOver = (element, struct) -> trace('over');
		onPointerOut = (element, struct) -> trace('out');
	}

	public function change_spell(key: SpellType)
	{
		config = Configurations.spells[key];
		tile.tile_index = config.tile_index;
	}
}

@:publicFields
@:structInit
class SpellConfig
{
	var name: String;
	var tile_index: Int;
	var damage: Int;
	var hit_box: Int;
	var cool_down: Float;
	var duration: Float;
	var speed: Float;
	var key: SpellType;
}
