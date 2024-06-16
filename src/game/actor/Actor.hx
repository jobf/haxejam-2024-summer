package game.actor;

import lib.peote.Elements;
import lib.pure.Calculate;
import lib.pure.Rectangle;

using lib.peote.TextureTools;
using lib.pure.EulerMotion;

@:publicFields
class Actor
{
	public var debug_hit_box(default, null): Blank;
	public var sprite(default, null): Sprite;
	public var movement(default, null): MotionComponent;

	var speed: Float = 1800;
	var can_move: Bool = true;

	public var facing: Int = 1;

	var is_expired: Bool = false;
	var animation_tile_indexes: Array<Int>;
	var animation_frame_index: Int = 0;
	var animation_duration: Float = 0.25;
	var animation_timer: Float = 0.25;
	var direction_x: Int = 0;
	var direction_y: Int = 0;
	var health: Float = 1;
	var rect: Rectangle;
	var hit_box: Rectangle;
	var overlap: Rectangle;
	var level: Level;
	var padding: Int = 8;

	public function new(cell_size: Int, sprite: Sprite, debug_hit_box:Blank, animation_tile_indexes: Array<Int>, level: Level)
	{
		this.sprite = sprite;
		this.debug_hit_box = debug_hit_box;
		this.level = level;
		this.animation_tile_indexes = animation_tile_indexes;

		rect = {
			x: sprite.x,
			y: sprite.y,
			width: cell_size - padding,
			height: cell_size - padding,
		}

		hit_box = {
			x: rect.x,
			y: rect.y,
			width: rect.width,
			height: rect.height,
		}

		overlap = {
			x: 0,
			y: 0,
			width: 0,
			height: 0,
		}
		wall = {
			x: -100,
			y: -100,
			width: cell_size,
			height: cell_size,
		}
		movement = new MotionComponent(rect.x, rect.y, cell_size);
		movement.deceleration_x = 2000;
		movement.deceleration_y = 2000;
		movement.velocity_max_x = 300;
		movement.velocity_max_y = 300;
		movement.compute_motion(0);
	}

	function is_moving(): Bool
	{
		return movement.velocity_x != 0 || movement.velocity_y != 0;
	}

	var scale = 4;

	var wall: Rectangle;

	// wall_tile_at: (x: Float, y: Float) -> Null<Rectangle>
	public function update(elapsed_seconds: Float)
	{
		if (can_move)
		{
			movement.compute_motion(elapsed_seconds);
		}
		rect.x = movement.position_x;
		rect.y = movement.position_y;
		hit_box.x = rect.x - (hit_box.width / 2);
		hit_box.y = rect.y - (hit_box.height / 2);

		var next_x = movement.next_x(elapsed_seconds);
		var next_column = movement.to_cell(next_x);
		var next_y = movement.next_y(elapsed_seconds);
		var next_row = movement.to_cell(next_y);

		// left
		if (movement.wasMovingLeft() && level.is_wall_cell(next_column, movement.row))
		{
			
			wall.x = next_column * movement.cell_size;
			wall.y = movement.row * movement.cell_size;
			wall.overlap_with(overlap, rect);
			if (overlap.width < padding)
			{
				movement.velocity_x = 0;
				movement.acceleration_x = 0;
				rect.x = rect.x + overlap.width;
			}
		}

		// right
		next_column += 1;
		if (movement.wasMovingRight() && level.is_wall_cell(next_column, movement.row))
		{
			wall.x = next_column * movement.cell_size;
			wall.y = movement.row * movement.cell_size;
			wall.overlap_with(overlap, rect);
			if (overlap.width > padding)
			{
				movement.velocity_x = 0;
				movement.acceleration_x = 0;
				rect.x = rect.x - overlap.width;
			}
		}

		// up
		if (movement.wasMovingUp() && level.is_wall_cell(movement.column, next_row))
		{
			// wall = level.wall_rect_at(next_x, next_y);
			wall.x = movement.column * movement.cell_size;
			wall.y = next_row * movement.cell_size;
			wall.overlap_with(overlap, rect);
			if (overlap.height < padding)
			{
				movement.velocity_y = 0;
				movement.acceleration_y = 0;
				rect.y = rect.y + overlap.height;
			}
		}

		// down
		next_row += 1;
		if (movement.wasMovingDown() && level.is_wall_cell(movement.column, next_row))
		{
			wall.x = movement.column * movement.cell_size;
			wall.y = next_row * movement.cell_size;
			wall.overlap_with(overlap, rect);
			if (overlap.height > padding)
			{
				movement.velocity_y = 0;
				movement.acceleration_y = 0;
				rect.y = rect.y - overlap.height;
			}
		}

		facing = movement.velocity_x < 0 ? -1 : 1;

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
		if(health <= 0 && is_expired){
			sprite.tint.a = 0;
			// is_expired = true;
		}

		if (tint_fade < 1)
		{
			tint_fade *= 1.1;
		}
		else
		{
			tint_fade = 1.0;
		}
		sprite.tint.g = Std.int(0xff * tint_fade);
		sprite.tint.b = sprite.tint.g;
	}

	public function draw()
	{
		sprite.x = rect.x;
		sprite.y = rect.y;
		// debug_hit_box.tint.a = 0x00;
		debug_hit_box.x = hit_box.x;
		debug_hit_box.y = hit_box.y;
		debug_hit_box.width = Std.int(hit_box.width);
		debug_hit_box.height = Std.int(hit_box.height);
		sprite.facing_x = -facing;
	}

	public function move_in_direction_x(direction: Int)
	{
		// if (direction != 0)
		// {
		// 	facing = direction;
		// }
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
		// sprite.tint.a = 0xff;
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

	var tint_fade: Float = 1.0;

	public function damage(amount: Float)
	{
		if(tint_fade >= 1){

			health -= amount;
			sprite.tint.g = 0;
			sprite.tint.b = 0;
			tint_fade = 0.01;
		}
	}
}
