package lib.pure;

/**
	fast, imprecise linear interpolation
**/
inline function lerp(a:Float, b:Float, t:Float):Float {
	return a + (b - a) * t;
}

/**
	distance between 2 points 
**/
inline function distance_to_point(x_a:Float, y_a:Float, x_b:Float, y_b:Float):Float {
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;
	return Math.sqrt(x_d * x_d + y_d * y_d);
}

inline function round_to_multiple(value:Float, multiple:Int):Int {
	return Math.ceil(value / multiple) * multiple;
}

inline function wrapped_increment(current:Int, increment:Int, maximum:Int):Int {
	return (current + maximum + increment) % maximum;
}

inline function radians_between(x_a:Float, y_a:Float, x_b:Float, y_b:Float):Float {
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;

	return Math.atan2(x_d, y_d);
}

inline function degrees_between(x_a:Float, y_a:Float, x_b:Float, y_b:Float):Float {
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;

	return Math.atan2(x_d, y_d) * to_degrees();
}

inline function to_degrees():Float {
	return 180 / Math.PI;
}

inline function to_rad():Float {
	return Math.PI / 180;
}
