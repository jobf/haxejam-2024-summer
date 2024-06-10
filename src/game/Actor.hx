package game;

import lib.peote.Elements;

using lib.peote.TextureTools;
using lib.pure.Cache;
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

@:publicFields
@:structInit
class ProjectileConfig {
	var sprite:Sprite;
	var life_time:Float = 5.0;
	var speed:Float = 300;
}

class Projectile extends Actor {
	var is_expired:Bool = false;
	var is_updating:Bool = true;
	var config:ProjectileConfig;
	var life_time:Float = 0;
	var alpha:Float = 1;

	function new(config:ProjectileConfig) {
		super(config.sprite);
		sprite.tint.a = 0;
		this.config = config;
	}

	function emit(direction_x:Float, direction_y:Float) {}

	override function update(elapsed_seconds:Float) {
		if (is_updating) {
			super.update(elapsed_seconds);
			life_time -= elapsed_seconds;
			if (life_time <= 0) {
				is_expired = true;
			}
			if (is_expired && sprite.tint.a > 0) {
				alpha -= 0.01;
				sprite.tint.a -= 1;
			} else {
				is_updating = false;
			}
		}
	}

	public function reset(x:Float, y:Float, facing_x:Int) {
		is_expired = false;
		is_updating = true;

		movement.position_x = x;
		movement.position_previous_x = x;
		movement.position_y = y;
		movement.position_previous_y = y;
		alpha = 1;
		facing = facing_x;
		sprite.tint.a = 0xff;
		sprite.x = x;
		sprite.y = y;
	}
}

class Magician extends Actor {
	var cache:Cache<Projectile>;

	public function new(x:Float, y:Float, sprites:Sprites) {
		var tile_index = 32;
		cache = {
			cached_items: [],
			create: () -> new Projectile({
				sprite: sprites.make(0, 0, 512),
				life_time: 0.5,
				speed: 50
			}),
			cache: projectile -> projectile.sprite.tint.a = 0,
			item_limit: 15,
		};
		super(sprites.make(x, y, tile_index));
	}

	override function update(elapsed_seconds:Float) {
		super.update(elapsed_seconds);
		for (cached in cache.cached_items) {
			if (!cached.is_waiting) {
				cached.item.update(elapsed_seconds);
				if (!cached.item.is_updating) {
					cache.put(cached.item);
				}
			}
		}
	}

	override function draw() {
		super.draw();
		for (cached in cache.cached_items) {
			if (!cached.is_waiting) {
				cached.item.sprite.tint.a = Std.int(cached.item.alpha * 0xff);
				cached.item.draw();
			}
		}
	}

	public function cast_spell() {
		var projectile = cache.get();
		if (projectile != null) {
			var x = movement.position_x + (direction_x * sprite.width);
			var y = movement.position_y + (direction_y * sprite.height);
			projectile.reset(x, y, facing);
			projectile.sprite.tile_index = 0;

			if (direction_x != 0) {
				projectile.move_in_direction_x(direction_x);
			}
			if (direction_y != 0) {
				projectile.move_in_direction_y(direction_y);
			}
			trace('cast spell');
		}
	}

	public function show_spells() {}
}
