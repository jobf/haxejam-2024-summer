package game.actor;

import lib.peote.Elements;
import lib.pure.Calculate;

using lib.peote.TextureTools;
using lib.pure.EulerMotion;

@:publicFields
class Actor {
	public var sprite(default, null):Sprite;
	public var movement(default, null):MotionComponent;

	var speed:Float = 500;

	public var facing:Int = 1;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;
	var tile_index:Int;
	var animation_duration:Float = 0.45;
	var animation_timer:Float = 0.45;
	var direction_x:Int = 0;
	var direction_y:Int = 0;

	public function new(sprite:Sprite) {
		this.sprite = sprite;
		tile_index = sprite.tile_index;
		movement = new MotionComponent(sprite.x, sprite.y);
		movement.deceleration_x = 900;
		movement.deceleration_y = 900;
		movement.velocity_max_x = 300;
		movement.velocity_max_y = 300;
	}

	public function update(elapsed_seconds:Float) {
		movement.compute_motion(elapsed_seconds);
		if (movement.acceleration_x != 0 || movement.acceleration_y != 0) {
			animation_timer -= elapsed_seconds;
			if (animation_timer <= 0) {
				sprite.tile_index = sprite.tile_index == tile_index ? tile_index + 1 : tile_index;
				animation_timer = animation_duration;
			}
		}
	}

	public function draw() {
		sprite.x = movement.position_x;
		sprite.y = movement.position_y;
		sprite.facing_x = -facing;
	}

	public function move_in_direction_x(direction:Int) {
		if (direction != 0) {
			facing = direction;
		}
		direction_x = direction;
		direction_y = 0;
		movement.acceleration_x = direction * speed;
	}

	public function stop_x() {
		movement.acceleration_x = 0;
		// direction_x = 0;
	}

	public function move_in_direction_y(direction:Int) {
		movement.acceleration_y = direction * speed;
		direction_y = direction;
		direction_x = 0;
	}

	public function stop_y() {
		movement.acceleration_y = 0;
		// direction_y = 0;
	}

	public function dash() {}
}
