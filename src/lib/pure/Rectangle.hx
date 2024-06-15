package lib.pure;

/**
	A simple abstraction of a Rectangle
	x and y are top left but you can easily determine left, right, top, down and center 
**/
@:structInit
@:publicFields
class Rectangle
{
	var x: Float;
	var y: Float;
	var width: Float;
	var height: Float;
	

	var left(get, never): Float;

	private function get_left(): Float
	{
		return x;
	}

	var right(get, never): Float;

	private function get_right(): Float
	{
		return x + width;
	}

	var top(get, never): Float;

	private function get_top(): Float
	{
		return y;
	}

	var bottom(get, never): Float;

	private function get_bottom(): Float
	{
		return y + height;
	}

	var center_x(get, never): Float;

	private function get_center_x(): Float
	{
		return x + (width * 0.5);
	}

	var center_y(get, never): Float;

	private function get_center_y(): Float
	{
		return y + (height * 0.5);
	}

	public function is_inside(x: Float, y: Float): Bool
	{
		return left <= x && right >= x && top <= y && bottom >= y;
	}

	public function overlap_with(overlap:Rectangle, that: Rectangle): Void
	{
		overlap.x = 0;
		overlap.y = 0;
		overlap.width = 0;
		overlap.height = 0;
		var left = (this.x > that.x) ? this.x : that.x;
		var right1 = this.x + this.width;
		var right2 = that.x + that.width;
		var right = (right1 < right2) ? right1 : right2;
		var top = (this.y > that.y) ? this.y : that.y;
		var bottom1 = this.y + this.height;
		var bottom2 = that.y + that.height;
		var bottom = (bottom1 < bottom2) ? bottom1 : bottom2;

		if ((left < right) && (top < bottom))
		{
			overlap.x = left;
			overlap.y = top;
			overlap.width = right - left;
			overlap.height = bottom - top;
		}
	}
}
