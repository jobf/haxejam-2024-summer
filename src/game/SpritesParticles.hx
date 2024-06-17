package game;

import lib.peote.Elements;
import lib.pure.Cache;
import lib.pure.EulerMotion;
import lib.pure.Particles;

class SpritesParticles extends Particles<Sprite>
{
	var blanks: Sprites;

	public function new(core: Core, sprites:Sprites)
	{
		blanks = sprites;

		var particle_blueprint: ParticleConfig<Sprite> = {
			velocity_x: 8500,
			velocity_y: 8500,
			lifetime: 2.3,
			draw: (item, x, y) ->
			{
				item.x = x;
				item.y = y;
			},
			change_angle: (item, angle) -> item.angle = angle,
			change_alpha: (item, a) -> item.tint.a = a,
			change_tint: (item, tint) -> item.tint = tint,
			change_xy: (item, x, y) ->
			{
				item.x = x;
				item.y = y;
			}
		}

		var cache: Cache<Particle<Sprite>> = {
			cached_items: [],
			create: () -> new Particle(sprites.make(-100, -100, 3), particle_blueprint),
			cache: particle -> particle.hide(),
			item_limit: 100,
		}
		super(core.screen.res_limits, cache);
	}

	override function update(elapsed_seconds: Float)
	{
		super.update(elapsed_seconds);
		blanks.update_all();
	}
}
