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

	public function new(cell_size: Int, sprite: Sprite, animation_tile_indexes: Array<Int>)
	{
		this.sprite = sprite;
		this.animation_tile_indexes = animation_tile_indexes;
		movement = new MotionComponent(sprite.x, sprite.y, cell_size);
		movement.deceleration_x = 2000;
		movement.deceleration_y = 2000;
		movement.velocity_max_x = 300;
		movement.velocity_max_y = 300;
	}

	var scale = 4;

	public function update(elapsed_seconds: Float, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		movement.compute_motion(elapsed_seconds);

		var next_x = movement.next_x(elapsed_seconds);
		var next_column = movement.to_cell(next_x);
		var next_y = movement.next_y(elapsed_seconds);
		var next_row = movement.to_cell(next_y);
		var direction_h = movement.velocity_x > 0 ? 1 : movement.velocity_x < 0 ? -1 : 0;
		var direction_v = movement.velocity_y > 0 ? 1 : movement.velocity_y < 0 ? -1 : 0;
		var is_collision_h = has_wall_tile_at(next_column + direction_h, movement.row);
		var is_collision_v = has_wall_tile_at(movement.column, next_row + direction_v);

		if (is_collision_h)
		{
			movement.position_x = (next_column) * movement.cell_size;
			movement.velocity_x = 0;
			movement.acceleration_x = 0;
		}
		if (is_collision_v)
		{
			movement.position_y = (next_row) * movement.cell_size;
			movement.velocity_y = 0;
			movement.acceleration_y = 0;
		}
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
