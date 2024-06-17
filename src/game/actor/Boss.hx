package game.actor;

import lib.peote.Elements;
import lib.pure.Bresenham;
import lib.pure.Cache;
import lib.pure.Calculate;
import lib.pure.Countdown;
import lib.pure.Rectangle;
import slide.Slide;
import game.Configurations;
import game.LdtkData;
import game.actor.Enemy;

@:publicFields
class Boss extends Enemy
{
	var attacks: Array<SpellType> = [
		BOLT,
		BONESPEAR,
		FIREBALL,
		INFEST,
		LIGHTNING,
		PUNCH,
		STARMISSILE,
		// DRAGON,
		SKELETON,
	];
	var attack_index: Int = 0;
	var particles: SpritesParticles;

	function new(x: Float, y: Float, cell_size: Int, sprites: Sprites, debug_hit_box: Blank, config: EnemyConfig, cache: Cache<Projectile>, hero: Magician,
			level: Level, summon: Summon, enemies: Array<Enemy>)
	{
		super(x, y, cell_size, sprites, debug_hit_box, config, cache, hero, level, summon, enemies);
		particles = new SpritesParticles(hero.core, sprites);
	}

	override function update(elapsed_seconds: Float)
	{
		super.update(elapsed_seconds);
		attack_index = wrapped_increment(attack_index, 1, attacks.length);
		spell_config = Configurations.spells[attacks[attack_index]];
		spell_countdown.duration = spell_config.cool_down;

		if (is_dead)
		{
			particles.emit(rect.x, rect.y);
		}

		particles.update(elapsed_seconds);
	}
}
