package game.actor;

import lib.peote.Elements;
import lib.pure.Calculate;

class Projectile extends Actor {
	var is_expired:Bool = false;
	var is_updating:Bool = false;
	var config:ProjectileConfig;
	var life_time:Float = 0;
	var alpha:Float = 1;

	function new(config:ProjectileConfig) {
		super(config.sprite, config.animation_tile_indexes);
		this.config = config;
	}

	override function update(elapsed_seconds:Float) {
		super.update(elapsed_seconds);
		if (life_time > 0) {
			life_time -= elapsed_seconds;
			// alpha -= 0.01;
		} else {
			is_expired = true;
			trace('expire projectil');
			// if (!is_expired) {
			// }
		}
		// trace(life_time);
	}

	public function reset(x:Float, y:Float, facing_x:Int) {
		life_time = config.life_time;
		is_expired = false;
		is_updating = true;
		movement.velocity_x = 0;
		movement.velocity_y = 0;
		movement.acceleration_x = 0;
		movement.acceleration_y = 0;
		movement.position_x = x;
		movement.position_previous_x = x;
		movement.position_y = y;
		movement.position_previous_y = y;
		alpha = 1;
		facing = facing_x;
		sprite.tint.a = 0xff;
		sprite.x = x;
		sprite.y = y;
		trace('reset projectil $life_time');
	}

	public function move_towards_angle(angle:Float) {
		var angle_offset = -angle - 180;
		sprite.angle = angle; // * to_degrees();
		trace(sprite.angle);
		movement.acceleration_x = Math.cos(angle_offset) * config.speed;
		movement.acceleration_y = Math.sin(angle_offset) * config.speed;
	}
}

@:publicFields
@:structInit
class ProjectileConfig {
	var sprite:Sprite;
	var life_time:Float = 2.8;
	var speed:Float = 1000;
	var animation_tile_indexes:Array<Int> = [0];
}
