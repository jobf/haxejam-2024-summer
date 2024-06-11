package game;

import game.LdtkData;
import game.actor.Enemy.EnemyConfig;

var monsters: Map<Enum_Monster, EnemyConfig> = [
	Skeleton => {
		collision_radius: 16,
		animation_tile_indexes: [67, 68]
	},
	Zombie => {
		collision_radius: 16,
		animation_tile_indexes: [64, 65]
	},
	Spider => {
		collision_radius: 16,
		animation_tile_indexes: [67, 68] // todo
	},
	Necromancer => {
		collision_radius: 16,
		animation_tile_indexes: [67, 68] // todo
	},
];
