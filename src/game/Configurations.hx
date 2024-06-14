package game;

import game.Inventory;
import game.LdtkData;

var monsters: Map<Enum_Monster, EnemyConfig> = [
	Skeleton => {
		collision_radius: 16,
		animation_tile_indexes: [66, 67],
		drop: BONESPEAR,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 20,
		sight_grid_limit: 3
	},
	Zombie => {
		collision_radius: 16,
		animation_tile_indexes: [64, 65],
		drop: PUNCH,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 20,
		sight_grid_limit: 4
	},
	Spider => {
		collision_radius: 16,
		animation_tile_indexes: [67, 68], // todo
		drop: BONESPEAR,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 20,
		sight_grid_limit: 3
	},
	Necromancer => {
		collision_radius: 16,
		animation_tile_indexes: [67, 68], // todo
		drop: SKELETON,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 20,
		sight_grid_limit: 5
	},
];

@:publicFields
@:structInit
class EnemyConfig
{
	var collision_radius: Float;
	var animation_tile_indexes: Array<Int>;
	var drop: SpellType;
	var velocity_max: Float;
	var deceleration: Float;
	var speed: Float;
	var movement_duration: Float;
	var shooting_duration: Float;
	var health:Int;
	var sight_grid_limit:Int;
}

enum SpellType
{
	EMPTY;
	BOLT;
	BONESPEAR;
	DRAGON;
	FIREBALL;
	INFEST;
	LIGHTNING;
	PUNCH;
	SKELETON;
	STARMISSILE;
}

var spells: Map<SpellType, SpellConfig> = [
	EMPTY => {
		name: "",
		tile_index: 31,
		damage: 0,
		hit_box: 0,
		cool_down: 0,
		duration: 0,
		speed: 0,
		key: EMPTY,
	},
	FIREBALL => {
		name: "Fireball",
		tile_index: 4,
		damage: 40,
		hit_box: 16,
		cool_down: 2.0,
		duration: 12.0,
		speed: 1000,
		key: FIREBALL,
	},
	PUNCH => {
		name: "Punch",
		tile_index: 6,
		damage: 20,
		hit_box: 8,
		cool_down: 1.0,
		duration: 1.0,
		speed: 300,
		key: PUNCH,
	},
	BONESPEAR => {
		name: "Bone spear",
		tile_index: 3,
		damage: 20,
		hit_box: 4,
		cool_down: 1.0,
		duration: 6.0,
		speed: 1000,
		key: BONESPEAR,
	},
	BOLT => {
		name: "Holy bolt",
		tile_index: 2,
		damage: 100,
		hit_box: 4,
		cool_down: 2.0,
		duration: 5.0,
		speed: 300,
		key: BOLT,
	},
	DRAGON => {
		name: "Summon dragon",
		tile_index: 14,
		damage: 30,
		hit_box: 32,
		cool_down: 60.0,
		duration: 60.0,
		speed: 200,
		key: DRAGON,
	},
	INFEST => {
		name: "Infest",
		tile_index: 7,
		damage: 10,
		hit_box: 2,
		cool_down: 5.0,
		duration: 3.0,
		speed: 400,
		key: INFEST,
	},
	LIGHTNING => {
		name: "Lightning Strike",
		tile_index: 0,
		damage: 50,
		hit_box: 2,
		cool_down: 1.0,
		duration: 5.0,
		speed: 1000,
		key: LIGHTNING,
	},
	SKELETON => {
		name: "Summon Skeleton",
		tile_index: 15,
		damage: 10,
		hit_box: 8,
		cool_down: 60.0,
		duration: 60.0,
		speed: 100,
		key: SKELETON,
	},
	STARMISSILE => {
		name: "Star missile",
		tile_index: 8,
		damage: 10,
		hit_box: 2,
		cool_down: 0.5,
		duration: 5.0,
		speed: 300,
		key: STARMISSILE,
	},
];
