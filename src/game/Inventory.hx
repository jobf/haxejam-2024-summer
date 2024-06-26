package game;

import lib.peote.Elements;
import lib.peote.Glyph;
import lime.utils.Assets;
import peote.ui.interactive.UIElement;
import slide.*;
import game.Configurations;

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
	var spell_config: SpellConfig;
	var x: Float;
	var y: Float;
	var alpha: Float;

	function new(core: Core)
	{
		this.core = core;
		this.x = 0;
		this.y = 0;
		this.alpha = 1.0;
		spell_config = {
			name: "",
			tile_index: 31,
			damage: 0,
			hit_box: 0,
			cool_down: 0,
			duration: 0,
			speed: 0,
			key: EMPTY,
			priority: 0,
			color: 0xffffffFF
		};
		blanks = new Blanks(core.screen.display_hud);
		var font: FontModel = {
			element_width: 16,
			element_height: 16,
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-zx-origins_anvil-16.png",
		}
		var tile_size: Int = 16;
		var button_tile_size = 6 * tile_size;
		var equipped_tile_size = 12 * tile_size;

		glyphs = new Glyphs(core.screen.display_hud, font);

		var help = glyphs.make_line(40, 440, "CLICK TO TOGGLE SPELLS", 0x663931FF);
		var help = glyphs.make_line(40, 480, "PRESS H TO HIDE/SHOW INVENTORY", 0x663931FF);
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
			0xeec39aef
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
					{
						name: "",
						tile_index: 31,
						damage: 0,
						hit_box: 0,
						cool_down: 0,
						duration: 0,
						speed: 0,
						key: EMPTY,
						priority: 0,
						color: 0xffffffFF
					},
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
				{
					name: "",
					tile_index: 31,
					damage: 0,
					hit_box: 0,
					cool_down: 0,
					duration: 0,
					speed: 0,
					key: EMPTY,
					priority: 0,
					color: 0xffffffFF
				},
				clear
			);

			core.screen.display_hud.add(button);
			active_slots.push(button);
		}
	}

	public function update()
	{
		core.screen.display_hud.y = Std.int(y);
		core.screen.display_hud.x = Std.int(x);
	}

	var is_enabled: Bool = true;

	function enable()
	{
		is_enabled = true;
		core.screen.display_hud.show();
	}

	function disable()
	{
		is_enabled = false;
		core.screen.display_hud.hide();
	}

	public function toggle_visibility()
	{
		if(is_enabled){
			trace('slide out');
			Slide.tween(this)
				.to({y: core.screen.res_height}, 0.5)
				.ease(slide.easing.Quad.easeIn) //
				.onComplete(disable)
				.start();
		}
		else
		{
			trace('slide in');
			core.screen.display_hud.show();
			Slide.tween(this)
				.to({y: 0.1}, 0.5)
				.ease(slide.easing.Quad.easeIn) //
				.onComplete(enable)
				.start();
		}
	}

	function make_available(key: SpellType)
	{
		// trace('make available $key');
		var available = button_slots.filter(button -> key == button.config.key);
		if (available.length == 0)
		{
			Global.spellbook.push(key);
			for (button in button_slots)
			{
				if (button.config.key == EMPTY)
				{
					button.change_spell(key);
					tiles.update_element(button.tile);
					break;
				}
			}

			if (key != STARMISSILE)
			{
				toggle_visibility();
			}
		}
		else
		{
			trace('is already available $key');
		}
	}

	function combine()
	{
		var configs = active_slots.map(button -> button.config).filter(config -> config.key != EMPTY);
		if (configs.length > 1)
		{
			trace('combine!');
			// sort so that larger priority number is config a
			haxe.ds.ArraySort.sort(configs, (a, b) -> a.priority > b.priority ? 1 : -1);
			var a = configs[0];
			var b = configs[1];
			spell_config.tile_index = a.tile_index;
			trace('sprite of ${a.key}');
			spell_config.color = b.color;
			trace('color of ${b.key}');
			spell_config.duration = a.duration + b.duration;
			spell_config.hit_box = a.hit_box + b.hit_box;
			spell_config.cool_down = (a.cool_down + b.cool_down) / 2;
			spell_config.speed = (a.speed + b.speed) / 2;
			spell_config.hit_box = a.hit_box + b.hit_box;
			spell_config.damage = a.damage + b.damage;
			spell_config.key = a.key;
		}
		else
		{
			var a = configs[0];
			if (a != null)
			{
				spell_config.tile_index = a.tile_index;
				spell_config.duration = a.duration;
				spell_config.hit_box = a.hit_box;
				spell_config.cool_down = a.cool_down;
				spell_config.speed = a.speed;
				spell_config.hit_box = a.hit_box;
				spell_config.damage = a.damage;
				spell_config.priority = a.priority;
				spell_config.key = a.key;
			}
		}
	}

	function activate(key: SpellType)
	{
		// trace('activate $key');
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
			combine();
		}
	}

	function clear(key: SpellType)
	{
		trace('clear $key');
		var activated = active_slots.filter(button -> button.config.key != EMPTY);
		if (activated.length > 1)
		{
			for (button in active_slots)
			{
				if (button.config.key == key)
				{
					button.change_spell(EMPTY);
					tiles.update_element(button.tile);
					trace('set button tile ${button.tile.tile_index}');
					combine();
					break;
				}
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
		// onPointerUp = (element, pointer_event) -> trace('release');
		// onPointerOver = (element, struct) -> trace('over');
		// onPointerOut = (element, struct) -> trace('out');
	}

	public function change_spell(key: SpellType)
	{
		var a = Configurations.spells[key];
		config.tile_index = a.tile_index;
		config.duration = a.duration;
		config.hit_box = a.hit_box;
		config.cool_down = a.cool_down;
		config.speed = a.speed;
		config.hit_box = a.hit_box;
		config.damage = a.damage;
		config.key = a.key;
		config.priority = a.priority;
		config.color = a.color;
		trace('change to $key');
		// config.dump();
		tile.tile_index = config.tile_index;
	}
}
