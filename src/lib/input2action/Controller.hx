package lib.input2action;

import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.GamepadAction;
import input2action.Input2Action;
import input2action.KeyboardAction;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.Window;

@:publicFields
class Controller
{
	static function init_action_config(): ActionConfig
	{
		return [
			{
				gamepad: GamepadButton.DPAD_LEFT,
				keyboard: [KeyCode.LEFT, KeyCode.A],
				action: "left"
			},
			{
				gamepad: GamepadButton.DPAD_RIGHT,
				keyboard: [KeyCode.RIGHT, KeyCode.D],
				action: "right"
			},
			{
				gamepad: GamepadButton.DPAD_UP,
				keyboard: [KeyCode.UP, KeyCode.W],
				action: "up"
			},
			{
				gamepad: GamepadButton.DPAD_DOWN,
				keyboard: [KeyCode.DOWN, KeyCode.S],
				action: "down"
			},
			{
				gamepad: GamepadButton.B,
				keyboard: KeyCode.H,
				action: "b"
			},
			{
				gamepad: GamepadButton.A,
				keyboard: [KeyCode.G],
				action: "a"
			},
			{
				gamepad: GamepadButton.START,
				keyboard: [KeyCode.RETURN, KeyCode.RETURN2, KeyCode.NUMPAD_ENTER],
				action: "start"
			},
			{
				gamepad: GamepadButton.BACK,
				keyboard: [KeyCode.BACKSPACE],
				action: "select"
			},
		];
	}
}

@:structInit
@:publicFields
class ControllerActions
{
	var left: ButtonAction = {};
	var right: ButtonAction = {};
	var up: ButtonAction = {};
	var down: ButtonAction = {};
	var a: ButtonAction = {};
	var b: ButtonAction = {};
	var start: ButtonAction = {};
	var select: ButtonAction = {};

	public function clone(): ControllerActions
	{
		return {
			left: left,
			right: right,
			up: up,
			down: down,
			a: a,
			b: b,
			start: start,
			select: select
		}
	}
}

@:structInit
@:publicFields
class ButtonAction
{
	var on_press: Void -> Void = () -> return;
	var on_release: Void -> Void = () -> return;
}

class Input
{
	var input2Action: Input2Action;
	var target: ControllerActions;

	public function new(window: Window)
	{
		target = {}

		var left_right: ButtonPair = {
			on_press_a: () -> target.left.on_press(),
			on_release_a: () -> target.left.on_release(),
			on_press_b: () -> target.right.on_press(),
			on_release_b: () -> target.right.on_release(),
		}

		var up_down: ButtonPair = {
			on_press_a: () -> target.up.on_press(),
			on_release_a: () -> target.up.on_release(),
			on_press_b: () -> target.down.on_press(),
			on_release_b: () -> target.down.on_release(),
		}

		var action_map: ActionMap = [
			"left" => {
				action: (isDown, player) ->
				{
					left_right.controlA(isDown);
				},
				up: true
			},
			"right" => {
				action: (isDown, player) ->
				{
					left_right.controlB(isDown);
				},
				up: true
			},
			"up" => {
				action: (isDown, player) ->
				{
					up_down.controlA(isDown);
				},
				up: true
			},
			"down" => {
				action: (isDown, player) ->
				{
					up_down.controlB(isDown);
				},
				up: true
			},
			"b" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.b.on_press();
					else
						target.b.on_release();
				},
				up: true
			},
			"a" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.a.on_press();
					else
						target.a.on_release();
				},
				up: true
			},
			"select" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.select.on_press();
					else
						target.select.on_release();
				},
				up: true
			},
			"start" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.start.on_press();
					else
						target.start.on_release();
				},
				up: true
			}
		];

		var action_config = Controller.init_action_config();

		input2Action = new Input2Action();

		var keyboard_action = new KeyboardAction(action_config, action_map);

		input2Action.addKeyboard(keyboard_action);

		Gamepad.onConnect.add(gamepad ->
		{
			var gamepad_action = new GamepadAction(gamepad.id, action_config, action_map);
			input2Action.addGamepad(gamepad, gamepad_action);
			gamepad.onDisconnect.add(() -> input2Action.removeGamepad(gamepad));
		});

		input2Action.registerKeyboardEvents(window);
	}

	public function change_target(target: ControllerActions)
	{
		this.target = target;
	}

	public function reset()
	{
		// input2Action.unRegisterKeyboardEvents();
	}
}

@:structInit
class ButtonPair
{
	var on_press_a: () -> Void = () -> return;
	var on_release_a: () -> Void = () -> return;
	var is_pressed_a: Bool = false;

	var on_press_b: () -> Void = () -> return;
	var on_release_b: () -> Void = () -> return;
	var is_pressed_b: Bool = false;

	public function controlA(is_button_pressed: Bool)
	{
		if (is_button_pressed)
		{
			is_pressed_a = true;
			on_press_a();
		}
		else
		{
			is_pressed_a = false;
			if (is_pressed_b)
			{
				on_press_b();
			}
			else
			{
				on_release_a();
			}
		}
	}

	public function controlB(is_button_pressed: Bool)
	{
		if (is_button_pressed)
		{
			is_pressed_b = true;
			on_press_b();
		}
		else
		{
			is_pressed_b = false;
			if (is_pressed_a)
			{
				on_press_a();
			}
			else
			{
				on_release_b();
			}
		}
	}
}
