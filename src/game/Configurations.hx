package game;

import game.LdtkData;

var monsters: Map<Enum_Monster, EnemyConfig> = [
	Skeleton => {
		key: Skeleton,
		tile_size: _16,
		hit_box_w: 32,
		hit_box_h: 48,
		animation_tile_indexes: [66, 67],
		spell: BONESPEAR,
		velocity_max: 100,
		deceleration: 4000,
		speed: 150,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 60,
		sight_grid_limit: 3
	},
	Zombie => {
		key: Zombie,
		tile_size: _16,
		hit_box_w: 32,
		hit_box_h: 48,
		animation_tile_indexes: [64, 65],
		spell: PUNCH,
		velocity_max: 100,
		deceleration: 4000,
		speed: 100,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 80,
		sight_grid_limit: 4
	},
	Necromancer => {
		key: Necromancer,
		tile_size: _32,
		hit_box_w: 48,
		hit_box_h: 112,
		animation_tile_indexes: [0, 1], // todo
		spell: SKELETON,
		velocity_max: 100,
		deceleration: 4000,
		speed: 100,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 200,
		sight_grid_limit: 5
	},
	Dragon => {
		key: Dragon,
		tile_size: _64,
		hit_box_w: 80,
		hit_box_h: 100,
		animation_tile_indexes: [0, 1, 2, 3, 4, 5],
		spell: SKELETON,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 300,
		sight_grid_limit: 5
	},
	Dragon_Electro => {
		key: Dragon_Electro,
		tile_size: _64,
		hit_box_w: 80,
		hit_box_h: 100,
		animation_tile_indexes: [6, 7, 8, 9, 10, 11],
		spell: LIGHTNING,
		velocity_max: 100,
		deceleration: 4000,
		speed: 130,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 300,
		sight_grid_limit: 5
	},
	Dragon_Fire => {
		key: Dragon_Fire,
		tile_size: _64,
		hit_box_w: 80,
		hit_box_h: 100,
		animation_tile_indexes: [12, 13, 14, 15, 16, 17],
		spell: FIREBALL,
		velocity_max: 100,
		deceleration: 4000,
		speed: 200,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 300,
		sight_grid_limit: 5
	},
	Dragon_Tamer_Priestess => {
		key: Dragon_Tamer_Priestess,
		tile_size: _16,
		hit_box_w: 48,
		hit_box_h: 56,
		animation_tile_indexes: [68, 69],
		spell: SKELETON,
		velocity_max: 100,
		deceleration: 4000,
		speed: 100,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 500,
		sight_grid_limit: 5
	},
	Haxe => {
		key: Haxe,
		tile_size: _32,
		hit_box_w: 48,
		hit_box_h: 48,
		animation_tile_indexes: [2, 3, 4, 5, 6],
		spell: SKELETON,
		velocity_max: 100,
		deceleration: 4000,
		speed: 100,
		movement_duration: 1.25,
		shooting_duration: 2.25,
		health: 1000,
		sight_grid_limit: 5
	},
];

@:publicFields
@:structInit
class EnemyConfig
{
	var key: Enum_Monster;
	var hit_box_w: Int;
	var hit_box_h: Int;
	var tile_size: TileSize;
	var animation_tile_indexes: Array<Int>;
	var spell: SpellType;
	var velocity_max: Float;
	var deceleration: Float;
	var speed: Float;
	var movement_duration: Float;
	var shooting_duration: Float;
	var health: Int;
	var sight_grid_limit: Int;
}

enum TileSize
{
	_16;
	_32;
	_64;
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
		priority: 0,
		color: 0xffffffFF,
	},
	FIREBALL => {
		name: "Fireball",
		tile_index: 4,
		damage: 40,
		hit_box: 32,
		cool_down: 2.0,
		duration: 2,
		speed: 1000,
		key: FIREBALL,
		priority: 7,
		color: 0xff6800FF,
	},
	PUNCH => {
		name: "Punch",
		tile_index: 6,
		damage: 40,
		hit_box: 48,
		cool_down: 1.0,
		duration: 0.75,
		speed: 1000,
		key: PUNCH,
		priority: 3,
		color: 0xc4dedfFF,
	},
	BONESPEAR => {
		name: "Bone spear",
		tile_index: 3,
		damage: 20,
		hit_box: 16,
		cool_down: 1.0,
		duration: 3.0,
		speed: 1000,
		key: BONESPEAR,
		priority: 4,
		color: 0xaeaeaeFF,
	},
	BOLT => {
		name: "Holy bolt",
		tile_index: 2,
		damage: 100,
		hit_box: 32,
		cool_down: 4.0,
		duration: 2.5,
		speed: 300,
		key: BOLT,
		priority: 8,
		color: 0xfffb03FF,
	},
	DRAGON => {
		name: "Summon dragon",
		tile_index: 14,
		damage: 30,
		hit_box: 32,
		cool_down: 10.0,
		duration: 60.0,
		speed: 200,
		key: DRAGON,
		priority: 1,
		color: 0x09c100FF,
	},
	INFEST => {
		name: "Infest",
		tile_index: 7,
		damage: 10,
		hit_box: 16,
		cool_down: 5.0,
		duration: 3.0,
		speed: 400,
		key: INFEST,
		priority: 9,
		color: 0xf308c9FF,
	},
	LIGHTNING => {
		name: "Lightning Strike",
		tile_index: 0,
		damage: 50,
		hit_box: 2,
		cool_down: 1.0,
		duration: 4.0,
		speed: 1000,
		key: LIGHTNING,
		priority: 5,
		color: 0x04c9feFF,
	},
	SKELETON => {
		name: "Summon Skeleton",
		tile_index: 15,
		damage: 10,
		hit_box: 32,
		cool_down: 10.0,
		duration: 60.0,
		speed: 100,
		key: SKELETON,
		priority: 2,
		color: 0xffffffFF,
	},
	STARMISSILE => {
		name: "Star missile",
		tile_index: 8,
		damage: 10,
		hit_box: 20,
		cool_down: 0.5,
		duration: 3.0,
		speed: 300,
		key: STARMISSILE,
		priority: 6,
		color: 0xfff300FF,
	},
];

@:publicFields
@:structInit
class SpellConfig
{
	var name: String;
	var tile_index: Int;
	var damage: Int;
	var hit_box: Int;
	var cool_down: Float;
	var duration: Float;
	var speed: Float;
	var key: SpellType;
	var priority: Int;
	var color: Int;
	// function dump()
	// {
	// 	trace('spell $name\n$tile_index\n$damage\n$hit_box\n$cool_down\n$duration\n$speed\n$key\n\n');
	// }
}

@:publicFields
class Global
{
	static var level_index: Int = 0;
	static var levels: Array<Int> = [0, 2, 4];
	/*
	ldtk.Level[#Level_0, 480x480] 0 0
	ldtk.Level[#Level_1, 256x256] 1
	ldtk.Level[#Level_2, 480x480] 2 1
 	ldtk.Level[#Level_3, 256x256] 3
	ldtk.Level[#Level_4, 240x240] 4 2
	*/
}
