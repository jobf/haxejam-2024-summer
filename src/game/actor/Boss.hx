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
	var attacks:Array<SpellType> = [
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
	var attack_index:Int = 0;
	override function update(elapsed_seconds:Float){
		super.update(elapsed_seconds);
		attack_index = wrapped_increment(attack_index, 1, attacks.length);
		spell_config = Configurations.spells[attacks[attack_index]];
		spell_countdown.duration = spell_config.cool_down;
	}
}
