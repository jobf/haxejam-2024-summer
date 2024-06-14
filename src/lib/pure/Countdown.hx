package lib.pure;

@:publicFields
class Countdown
{
	var duration: Float;
	var remaining: Float;
	var action: Countdown -> Void;
	var is_repeating: Bool;

	function new(duration: Float, action: Countdown -> Void, is_repeating: Bool = true)
	{
		this.duration = duration;
		this.remaining = duration;
		this.action = action;
		this.is_repeating = is_repeating;
	}

	function update(elapsed_seconds: Float)
	{
		remaining -= elapsed_seconds;
		if (remaining <= 0)
		{
			action(this);
			if (is_repeating)
			{
				remaining = duration;
			}
		}
	}
}
