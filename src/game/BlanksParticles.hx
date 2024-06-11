package game;

import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.EulerMotion;
import lib.pure.Particles;

class BlanksParticles extends Particles<Blank>
{
	var blanks: Blanks;

	public function new(core: Core)
	{
		blanks = new Blanks(core.screen.display);

		var particle_blueprint: ParticleConfig<Blank> = {
			velocity_x: 200,
			velocity_y: 200,
			lifetime: 2.2,
			draw: (item, x, y) ->
			{
				item.x = x;
				item.y = y;
			},
			change_angle: (item, angle) -> return,
			change_alpha: (item, a) -> item.tint.a = a,
			change_xy: (item, x, y) ->
			{
				item.x = x;
				item.y = y;
			}
		}

		var cache: Cache<Particle<Blank>> = {
			cached_items: [],
			create: () -> new Particle(blanks.make(-100, -100, 4), particle_blueprint),
			cache: particle -> particle.hide(),
			item_limit: 256,
		}
		super(core.screen.res_limits, cache);
	}

	override function update(elapsed_seconds: Float)
	{
		super.update(elapsed_seconds);
		blanks.update_all();
	}
}
