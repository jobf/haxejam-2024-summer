package game.actor;

import lib.peote.Elements;
import lib.pure.Calculate;
import game.Inventory;

class Projectile extends Actor
{
	var life_time: Float = 0;
	var alpha: Float = 1;

	function new(cell_size: Int, sprite: Sprite)
	{
		super(cell_size, sprite, [sprite.tile_index]);
	}

	override function update(elapsed_seconds: Float, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		super.update(elapsed_seconds, has_wall_tile_at);
		if (life_time > 0)
		{
			life_time -= elapsed_seconds;
			// trace(life_time);
			// alpha -= 0.01;
		}
		else
		{
			is_expired = true;
			// trace('expire projectil');
		}
	}

	public function reset(x: Float, y: Float, facing_x: Int, spell: SpellConfig)
	{
		life_time = spell.duration;
		speed = spell.speed;
		sprite.tile_index = spell.tile_index;
		animation_tile_indexes = [spell.tile_index];
		trace('set spell ${spell.name} tile ${sprite.tile_index} anim ${animation_tile_indexes} duration ${life_time}');
		alpha = 1;
		sprite.tint.a = 0xff;
		facing = facing_x;
		sprite.x = x;
		sprite.y = y;

		is_expired = false;
		movement.velocity_x = 0;
		movement.velocity_y = 0;
		movement.acceleration_x = 0;
		movement.acceleration_y = 0;
		movement.position_x = x;
		movement.position_previous_x = x;
		movement.position_y = y;
		movement.position_previous_y = y;
		// trace('reset projectil $life_time');
	}

	public function move_towards_angle(angle: Float)
	{
		// sprite.angle = angle;
		// trace(sprite.angle);
		movement.acceleration_y = Math.cos(angle) * speed;
		movement.acceleration_x = Math.sin(angle) * speed;
	}

	public function hide()
	{
		alpha = 0;
		sprite.tint.a = 0;
	}
}
