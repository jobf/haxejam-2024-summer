package lib.pure;

import lib.pure.Cache;
import lib.pure.Calculate.lerp;
import lib.pure.Rectangle;

using lib.pure.EulerMotion;

@:publicFields
class Particles<T>
{
	var cache: Cache<Particle<T>>;

	var tone: Int = 0xff030202;
	var tone_off: Int = 0xffffff00;
	var limits: Rectangle;

	public function new(limits: Rectangle, cache: Cache<Particle<T>>)
	{
		this.cache = cache;
		this.limits = limits;
	}

	var duration = 4;
	var remain = 0;
	var mouse_x: Float;
	var mouse_y: Float;

	public function update(elapsed_seconds: Float)
	{
		if (remain <= 0)
		{
			remain = duration;
		}
		else
		{
			remain--;
		}

		for (cached in cache.cached_items)
		{
			if (!cached.is_waiting)
			{
				cached.item.update(elapsed_seconds);
				if (cached.item.particle.lifetime < 0
					|| !limits.is_inside(cached.item.movement.position_x, cached.item.movement.position_y))
				{
					// trace('put');
					cache.put(cached.item);
				}
			}
		}
	}

	public function emit(x: Float, y: Float)
	{
		for (i in 0...13)
		{
			var item = cache.get();
			if (item != null)
			{
				item.configure(x, y);
				item.particle.change_angle(item.graphic, Math.random() * 360);
				item.particle.change_alpha(item.graphic, 0xff);
			}
		}
	}
}

@:structInit
@:publicFields
class ParticleConfig<T>
{
	var velocity_x: Float;
	var velocity_y: Float;
	var lifetime: Float;

	var draw: (item: T, x: Float, y: Float) -> Void;

	var change_angle: (item: T, angle: Float) -> Void;

	var change_alpha: (item: T, a: Int) -> Void;

	var change_xy: (item: T, x: Float, y: Float) -> Void;
}

@:publicFields
class Particle<T>
{
	var movement: MotionComponent;

	var graphic: T;
	var blueprint: ParticleConfig<T>;
	var particle: ParticleConfig<T>;

	function new(graphic: T, blueprint: ParticleConfig<T>)
	{
		this.graphic = graphic;
		this.blueprint = blueprint;
		this.particle = {
			velocity_x: blueprint.velocity_x,
			velocity_y: blueprint.velocity_y,
			lifetime: blueprint.lifetime,
			draw: blueprint.draw,
			change_angle: blueprint.change_angle,
			change_alpha: blueprint.change_alpha,
			change_xy: blueprint.change_xy
		};

		movement = new MotionComponent(-100, -100, 4);
	}

	public function hide()
	{
		particle.change_alpha(graphic, 0x00);
		particle.change_xy(graphic, -100, -100);
	}

	function configure(x: Float, y: Float)
	{
		movement.velocity_x = 0;
		movement.velocity_y = 0;
		movement.deceleration_x = 0;
		movement.deceleration_y = 0;
		movement.acceleration_x = ((Math.random() * blueprint.velocity_x - (blueprint.velocity_x / 2)));
		movement.acceleration_y = ((Math.random() * blueprint.velocity_y - (blueprint.velocity_y / 2)));
		particle.lifetime = Std.int(Math.random() * blueprint.lifetime);

		// movement.deceleration_x = 1500;
		// movement.deceleration_y = 1500;
		// movement.velocity_max_x = 200;
		// movement.velocity_max_y = 200;
		movement.velocity_max_x = 99999; // blueprint.velocity_x;
		movement.velocity_max_y = 99999; // blueprint.velocity_x;
		movement.teleport(x, y);
		particle.change_alpha(graphic, 0xff);
	}

	function update(elapsed_seconds: Float)
	{
		movement.compute_motion(elapsed_seconds);
		particle.change_xy(
			graphic,
			movement.position_x,
			movement.position_y
		);
		particle.lifetime -= elapsed_seconds;
		if (particle.lifetime < 0)
		{
			hide();
		}
	}
}
