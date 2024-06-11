package lib.pure;

@:publicFields
class MotionComponent
{
	function new(x: Float, y: Float, cell_size: Int)
	{
		position_x = x;
		position_previous_x = x;

		position_y = y;
		position_previous_y = y;

		this.cell_size = cell_size;
		column = Std.int(x / cell_size);
		cell_ratio_x = x - (column * cell_size);
		row = Std.int(y / cell_size);
		cell_ratio_y = y - (row * cell_size);
	}

	var cell_size: Int;
	var column: Int;
	var cell_ratio_x: Float;
	var row: Int;
	var cell_ratio_y: Float;

	/**
	 * Current x position in world space
	**/
	var position_x: Float;

	/**
	 * Previous x position in world space
	**/
	var position_previous_x: Float;

	/**
	 * Current y position in world space
	**/
	var position_y: Float;

	/**
	 * Previous y position in world space
	**/
	var position_previous_y: Float;

	/**
	 * Current x velocity
	**/
	var velocity_x: Float = 0.0;

	/**
	 * max x velocity permitted
	**/
	var velocity_max_x: Float = 0.0;

	/**
	 * Current y velocity
	**/
	var velocity_y: Float = 0.0;

	/**
	 * max y velocity permitted
	**/
	var velocity_max_y: Float = 0.0;

	/**
	 * How much velocity will speed up on x axis
	**/
	var acceleration_x: Float = 0.0;

	/**
	 * How much velocity will speed up on y axis
	**/
	var acceleration_y: Float = 0.0;

	/**
	 * How much velocity will slow down on x axes
	 * Note: only takes effect when Acceleration is zero
	**/
	var deceleration_x: Float = 0.0;

	/**
	 * How much velocity will slow down on y axes
	 * Note: only takes effect when Acceleration is zero
	**/
	var deceleration_y: Float = 0.0;

	function teleport(x: Float, y: Float)
	{
		position_x = x;
		position_previous_x = x;
		position_y = y;
		position_previous_y = y;
	}
}

class MotionComponentLogic
{
	/**
	 * Updates the speed and position of the MotionComponent 
	 * 2 deltas are calculated per axis to "help with higher fidelity framerate-independent motion.
	 * Based on FlxObject UpdateMotion https://github.com/HaxeFlixel/flixel/blob/dev/flixel/FlxObject.hx#L882
	 * @param motion				The motion component to be updated
	 * @param elapsed_seconds	The amount of time passed since last update frame
	**/
	public static function compute_motion(motion: MotionComponent, elapsed_seconds: Float)
	{
		// update x axis position and speed
		var vel_delta = 0.5 * (compute_axis(
			motion.velocity_x,
			motion.acceleration_x,
			motion.deceleration_x,
			motion.velocity_max_x,
			elapsed_seconds
		)
			- motion.velocity_x);
		motion.velocity_x = motion.velocity_x + vel_delta;
		var movement_delta = motion.velocity_x * elapsed_seconds;
		// keep record of previous position before setting new position based on the movement delta
		motion.position_previous_x = motion.position_x;
		motion.position_x = motion.position_x + movement_delta;
		motion.column = Std.int(motion.position_x / motion.cell_size);
		motion.cell_ratio_x = motion.position_x - (motion.column * motion.cell_size);
		motion.row = Std.int(motion.position_y / motion.cell_size);
		motion.cell_ratio_y = motion.position_y - (motion.row * motion.cell_size);
		// update y axis position and speed
		var vel_delta = 0.5 * (compute_axis(
			motion.velocity_y,
			motion.acceleration_y,
			motion.deceleration_y,
			motion.velocity_max_y,
			elapsed_seconds
		)
			- motion.velocity_y);
		motion.velocity_y = motion.velocity_y + vel_delta;
		var movement_delta = motion.velocity_y * elapsed_seconds;
		// keep record of previous position before setting new position based on the movement delta
		motion.position_previous_y = motion.position_y;
		motion.position_y = motion.position_y + movement_delta;
	}

	/**
	 * Takes a starting velocity and some other factors and returns an adjusted velocity
	 * Based on FlxVelocity ComputeVelocity - https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxVelocity_hx#L223
	 * @param	velocity				The velocity that should be adjusted
	 * @param	acceleration		Rate at which the velocity is changing.
	 * @param	deceleration		How much the velocity changes if Acceleration is not set.
	 * @param	velocity_max	An absolute value cap for the velocity (0 for no cap).
	 * @param	elapsed_seconds	The amount of time passed since last update frame
	 * @return	The adjusted Velocity value.
	**/
	inline static function compute_axis(velocity: Float, acceleration: Float, deceleration: Float, velocity_max: Float, elapsed_seconds: Float): Float
	{
		// velocity and acceleration are bipolar so can either be
		// - positive : moving up the axis - (x : right, y : down)
		// - negative : moving down the axis - (x : left, y : up)
		if (acceleration != 0)
		{
			// if acceleration is a non zero amount
			// it should have an effect on velocity
			var speed_up_by = acceleration * elapsed_seconds;
			// acceleration can cause the motion to reverse direction
			// (e.g. -2 + 10 = 8, 2 + -10 = -8)
			velocity += speed_up_by;
		}
		else
			if (deceleration != 0)
			{
				// if acceleration IS zero then deceleration can be applied
				// when deceleration is a non zero amount
				var slow_down_by = deceleration * elapsed_seconds;
				// applying enough deceleration to velocity could cross zero
				// which would cause the motion to tracel in the opposite direction
				// however deceleration is only used to slow motion down
				// it would be odd to have the motion change direction when slowing down
				// so some extra logic is needed

				if (velocity - slow_down_by > 0)
				{
					// only slow the motion if staying the same side of zero (e.g. direction does not change)
					velocity -= slow_down_by;
				}
				else
					if (velocity + slow_down_by < 0)
					{
						// only slow the motion if staying the same side of zero (e.g. direction does not change)
						velocity += slow_down_by;
					}
					else
					{
						// this branch is only reached when direction would change
						// in this case stop the motion by setting velocity to 0
						velocity = 0;
					}
			}

		// final checks to ensure that velocity did not increase/decrease
		// beyond the max velocity
		if ((velocity != 0) && (velocity_max != 0))
		{
			if (velocity > velocity_max)
			{
				velocity = velocity_max;
			}
			else
				if (velocity < -velocity_max)
				{
					velocity = -velocity_max;
				}
		}
		return velocity;
	}
}
