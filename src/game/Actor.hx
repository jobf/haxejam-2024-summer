package game;

import lib.peote.Elements;

using lib.peote.TextureTools;
using lib.pure.EulerMotion;

@:publicFields
class Actor {
	public var sprite(default, null):Sprite;
	public var movement(default, null):MotionComponent;

	var speed:Float = 50;

	public var direction_x:Int = 0;
	public var direction_y:Int = 0;
	public var facing:Int = 0;
	public var is_moving_x(get, never):Bool;

	function get_is_moving_x():Bool {
		return direction_x != 0;
	}

	var acceleration_x:Float = 0.15;

	public var velocity_x_max:Float = 0.62;
	public var velocity_y_max:Float = 0.7;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;
	var tile_index:Int;
	var animation_duration:Float = 0.45;
	var animation_timer:Float = 0.45;

	public function new(sprite:Sprite) {
		this.sprite = sprite;
		sprite.facing_x = -1;
		tile_index = sprite.tile_index;
		movement = new MotionComponent(sprite.x, sprite.y);
		movement.deceleration_x = 150;
		movement.deceleration_y = 150;
		movement.velocity_max_x = 70;
		movement.velocity_max_y = 70;
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
		facing = direction;
		direction_x = direction;
		movement.acceleration_x = direction * speed;
	}

	public function stop_x() {
		direction_x = 0;
		movement.acceleration_x = 0;
	}

	public function move_in_direction_y(direction:Int) {
		direction_y = direction;
		movement.acceleration_y = direction * speed;
	}

	public function stop_y() {
		direction_y = 0;
		movement.acceleration_y = 0;
	}

	public function dash() {}

	public function cast_spell() {}

	public function show_spells() {}
}
