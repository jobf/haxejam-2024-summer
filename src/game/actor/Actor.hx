package game.actor;

import lib.peote.Elements;
import lib.pure.Calculate;

using lib.peote.TextureTools;
using lib.pure.EulerMotion;

@:publicFields
class Actor
{
	public var sprite(default, null): Sprite;
	public var movement(default, null): MotionComponent;

	var speed: Float = 1800;

	public var facing: Int = 1;

	var is_expired: Bool = false;
	var animation_tile_indexes: Array<Int>;
	var animation_frame_index: Int = 0;
	var animation_duration: Float = 0.25;
	var animation_timer: Float = 0.25;
	var direction_x: Int = 0;
	var direction_y: Int = 0;
	var health: Float = 1;

	public function new(sprite: Sprite, animation_tile_indexes: Array<Int>)
	{
		this.sprite = sprite;
		this.animation_tile_indexes = animation_tile_indexes;
		movement = new MotionComponent(sprite.x, sprite.y);
		movement.deceleration_x = 2000;
		movement.deceleration_y = 2000;
		movement.velocity_max_x = 300;
		movement.velocity_max_y = 300;
	}

	public function update(elapsed_seconds: Float)
	{
		movement.compute_motion(elapsed_seconds);
		if (health <= 0)
		{
			is_expired = true;
			sprite.tint.a = 0;
		}
		if (movement.acceleration_x != 0 || movement.acceleration_y != 0)
		{
			animation_timer -= elapsed_seconds;
			if (animation_timer <= 0)
			{
				animation_frame_index = wrapped_increment(
					animation_frame_index,
					1,
					animation_tile_indexes.length
				);
				sprite.tile_index = animation_tile_indexes[animation_frame_index];
				animation_timer = animation_duration;
			}
		}
	}

	public function draw()
	{
		sprite.x = movement.position_x;
		sprite.y = movement.position_y;
		sprite.facing_x = -facing;
	}

	public function move_in_direction_x(direction: Int)
	{
		if (direction != 0)
		{
			facing = direction;
		}
		direction_x = direction;
		direction_y = 0;
		movement.acceleration_x = direction * speed;
	}

	public function stop_x()
	{
		movement.acceleration_x = 0;
		// direction_x = 0;
	}

	public function move_in_direction_y(direction: Int)
	{
		movement.acceleration_y = direction * speed;
		direction_y = direction;
		direction_x = 0;
	}

	public function stop_y()
	{
		movement.acceleration_y = 0;
		// direction_y = 0;
	}

	public function dash() {}

	public function damage(amount: Float)
	{
		health -= amount;
	}
}
