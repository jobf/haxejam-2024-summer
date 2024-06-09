package lib.pure;

import lib.input2action.Controller;

/* template

	class TScene extends Scene<GameCore>
	{
	public function begin() {}

	public function update(elapsed_ms:Int) {}

	public function draw() {}

	public function clean_up(): {}
	}

 */
@:publicFields
abstract class SceneBase<T>
{
	var core(default, null): T;

	function new(core: T)
	{
		this.core = core;
	}

	/**
		Handle scene set up here, e.g. set up level, player, etc.
	**/
	abstract public function begin(): Void;

	/**
		Handle loop logic here, e,g, calculating movement for player, change object states, etc.
		@param elapsed_ms is the number of milliseconds passed since the last step
	**/
	abstract public function update(elapsed_ms:Int): Void;

	/**
		Make draw calls here
	**/
	abstract public function draw(): Void;

	/**
		Clean up the scene here, e.g. remove elements from graphics buffers
	**/
	abstract public function clean_up(): Void;
}