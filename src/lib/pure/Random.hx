package lib.pure;

function float_between(min: Float, max: Float)
{
	return (min + Math.random() * (max - min));
}

function int_between(min: Float, max: Float)
{
	return Std.int(float_between(min, max));
}
