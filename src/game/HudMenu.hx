package game;

import lib.input2action.Controller;
import lib.peote.Glyph;
import lib.peote.Mouse.HotSpot;
import lib.pure.Menu;
import lib.pure.Node;
import lime.ui.MouseButton;
import lime.ui.Window;

class HudMenu
{
	var menu: Menu;

	public var controller: ControllerActions;

	var core: Core;
	var glyphs: Glyphs;
	var glyph_color_idle = 0x243d5cFF;
	var glyph_color_selected = 0xe0c872ff;

	var buttons: Array<Button>;
	var window: Window;

	public var is_open: Bool = false;

	var previous_controller: ControllerActions;
	var on_close: Void -> Void;

	public function new(core: Core, menu_config: MenuConfig)
	{
		this.core = core;
		core.screen.display_menu_hide();
		this.on_close = menu_config.on_close;
		var gap = 4;
		var line_height = 20;
		var x: Float = 10;
		var y: Float = 10;

		if (menu_config.is_aligned_to_bottom)
		{
			y = (core.screen.display_menu.height / core.screen.display_menu.zoom) - line_height;
			trace('hud menu start $y');
			line_height *= -1;
		}

		var font: FontModel = {
			element_width: 16,
			element_height: 16,
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-zx-origins_anvil-16.png",
		}

		glyphs = new Glyphs(core.screen.display_menu, font);

		menu = new Menu(menu_config.items, on_navigate);

		buttons = [];
		var line_height = font.element_height + gap;

		var button_creator: NodeVisitor<MenuItem> = {
			visit: (node, depth) ->
			{
				var button = new Button(
					glyphs.make_line(x, y, node.item.label, glyph_color_idle),
					{
						on_press: (button, mouse_button) ->
						{
							node.item.action();
						},
						// on_release: on_release,
						on_over: button ->
						{
							button.label.change_tint(glyph_color_selected);
							menu.change_selection(node.item);
						},
						on_slide: (button, amount) ->
						{
							var new_value = node.item.on_slide(node.item, amount);
							button.label.change_text('${button.label} $new_value');
						},
						// on_out: button -> button.label.change_tint(glyph_color_idle),
						x: x,
						y: y,
						width: font.element_width * node.item.label.length,
						height: font.element_height
					},
					node.item
				);

				buttons.push(button);
				y += line_height;
				core.screen.display_menu.add(button.interactive);
				button;
			}
		}

		menu.recurse_with(button_creator);

		controller = {
			left: {
				on_press: () -> menu.ascend(),
			},
			right: {
				on_press: () -> menu.descend(),
			},
			up: {
				on_press: () ->
				{
					menu.iterate_selection(-1);
				},
			},
			down: {
				on_press: () -> menu.iterate_selection(1),
			},
			a: {
				on_press: () -> menu.perform_selected_action(),
			},
			b: {
				on_press: () -> menu.perform_selected_action(),
			},
			start: {
				on_press: () -> menu.perform_selected_action(),
			},
			select: {
				on_press: () -> close(),
			}
		}

		on_navigate();
	}

	function on_navigate(): Void
	{
		for (button in buttons)
		{
			if (menu.selected_label() == button.label.text)
			{
				button.label.change_tint(glyph_color_selected);
				button.label.change_text(button.menu_item.label);
			}
			else
			{
				button.label.change_tint(glyph_color_idle);
			}
		}
	}

	public function open(previous_controller: ControllerActions)
	{
		// trace('open hud');
		// is_open = true;
		// core.screen.display_menu_show();
	}

	public function close()
	{
		// trace('close hud');
		// is_open = false;
		// core.screen.display_menu_hide();
	}

	public function dispose()
	{
		glyphs.clear();
		for (button in buttons)
		{
			core.screen.display_menu.remove(button.interactive);
		}
	}
}

@:publicFields
@:structInit
class MenuConfig
{
	var introduction: Array<String>;
	var items: Array<MenuItemConfig>;
	var is_aligned_to_bottom: Bool = false;
	var on_close: Void -> Void = () -> return;
}

@:publicFields
class Button
{
	var label: GlyphLine;
	var config: ButtonConfig;
	var interactive: HotSpot;
	var glyph_color_out = 0x243d5cFF;
	var glyph_color_over = 0x243d5cFF;
	var glyph_color_selected = 0xe0c872ff;
	var menu_item: MenuItem;

	public function new(label: GlyphLine, config: ButtonConfig, menu_item: MenuItem)
	{
		this.label = label;
		this.config = config;
		this.menu_item = menu_item;
		interactive = new HotSpot(config.x, config.y, config.width, config.height);
		interactive.on_out = () -> config.on_out(this);
		interactive.on_over = () -> config.on_over(this);
		interactive.on_press = mouse_button -> config.on_press(this, mouse_button);
		interactive.on_release = mouse_button -> config.on_release(this, mouse_button);
	}
}

class Numeric extends Button {}

@:publicFields
@:structInit
class ButtonConfig
{
	var on_press: (button: Button, mouse_button: MouseButton) -> Void = (button, mouse_button) -> return;
	var on_release: (Button, MouseButton) -> Void = (button, mouse_button) -> return;
	var on_over: Button -> Void = Button -> return;
	var on_out: Button -> Void = Button -> return;
	var on_slide: (button: Button, amount: Float) -> Void = (button, amount) -> return;
	var x: Float;
	var y: Float;
	var width: Float;
	var height: Float;
}
