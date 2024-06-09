package lib.peote;

import lime.ui.MouseButton;
import peote.ui.interactive.UIElement;

class HotSpot extends UIElement
{
	public var on_over: Void -> Void = () -> return;
	public var on_out: Void -> Void = () -> return;
	public var on_press: MouseButton -> Void = button -> return;
	public var on_release: MouseButton -> Void = button -> return;
	public var on_press_left: Void -> Void = () -> return;
	public var on_press_right: Void -> Void = () -> return;

	public function new(x: Float, y: Float, width: Float, height: Float)
	{
		super(Std.int(x), Std.int(y), Std.int(width), Std.int(height));

		onPointerDown = (element, pointer_event) -> on_press(pointer_event.mouseButton);
		onPointerUp = (element, pointer_event) -> on_release(pointer_event.mouseButton);
		onPointerOver = (element, struct) -> on_over();
		onPointerOut = (element, struct) -> on_out();
		on_press_left = () -> return;
		on_press_right = () -> return;
	}
}
