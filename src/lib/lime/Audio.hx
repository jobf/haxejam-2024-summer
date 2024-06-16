package lib.lime;

import haxe.ds.Vector;
import lib.pure.Countdown;
import lime.app.Future;
import lime.math.Vector4;
import lime.media.AudioBuffer;
import lime.media.AudioSource;
import lime.utils.Assets;

class SoundManager
{
	var fade_out: Countdown;
	var fade_in: Countdown;
	var fade_amount_per_step: Float;
	var fade_target: Float;
	var is_fading_out: Bool = false;
	var is_fading_in: Bool = false;

	var music_load: Future<AudioBuffer>;
	var is_music_playing: Bool;
	var music: AudioSource;

	var sounds: Map<Int, Sound>;

	public function new()
	{
		fade_amount_per_step = 0.01;

		fade_out = new Countdown(1 / 60, countdown -> reduce_gain(), false);
		fade_in = new Countdown(1 / 60, countdown -> increase_gain(), false);
		sounds = [];
		trace('initialized SoundManager');
	}

	// var globalGain = 0.5;

	/**
		can only be called after lime preload complete
	**/
	public function play_music(asset_path: String, is_looped: Bool = true, gain: Float = 0.9)
	{
		if (music != null)
		{
			// do quick fade and start
			fade_out_to_target(() ->
			{
				stop_music();
				this.gain = gain;
				play_music(asset_path, is_looped);
			}, 0, 0.2);
		}
		else
		{
			#if web
			asset_path = StringTools.replace(asset_path, "ogg", "mp3");
			#end
			trace('called play_music($asset_path)');
			music_load = Assets.loadAudioBuffer(asset_path);
			music_load.onComplete(buffer ->
			{
				var loops = is_looped ? 1000 : 0;
				music = new AudioSource(buffer, 0, null, loops);
				music.gain = gain;
				trace('init music AudioSource');
				music.play();
				trace('called music.play()');
				is_music_playing = true;
			});
			music_load.onError(d ->
			{
				trace('error');
				trace(d);
			});
			music_load.onProgress((i1, i2) ->
			{
				trace('loading music progress $i1 $i2');
			});
		}
	}

	public function stop_music()
	{
		if (music != null && is_music_playing)
		{
			// do quick fade and stop
			fade_out_to_target(() ->
			{
				music.stop();
				music = null;
				is_music_playing = false;
			}, 0.0, 0.2);
		}
	}

	var last_known_gain: Float = 0.0;

	public function pause_music()
	{
		if (music != null && is_music_playing)
		{
			last_known_gain = gain;
			// do quick fade and pause
			fade_out_to_target(() ->
			{
				music.pause();
				is_music_playing = false;
			}, 0.0, 0.2);
		}
	}

	public function continue_music()
	{
		if (music != null && !is_music_playing)
		{
			// do quick fade and play
			fade_in_to_target(
				() ->
				{
					music.play();
					is_music_playing = true;
				},
				last_known_gain,
				0.2
			);
		}
	}

	/**
		load sounds from asset library	
		can only be called after lime preload complete
	**/
	public function load_sound_assets(keyed_paths: Map<Int, String>, voice_count: Int = 3)
	{
		for (key => asset_path in keyed_paths.keyValueIterator())
		{
			load_sound_asset(asset_path, key, voice_count);
		}
	}

	/**
		desktop targets must use ogg files, mp3 is better for web because safari does not support ogg
	**/
	inline function target_path(asset_path: String): String
	{
		#if web
		return StringTools.replace(asset_path, "ogg", "mp3");
		#else
		return StringTools.replace(asset_path, "mp3", "ogg");
		#end
	}

	public function load_sound_asset(asset_path: String, key: Int, voice_count: Int = 3)
	{
		var targetted_asset_path = target_path(asset_path);
		if (Assets.exists(targetted_asset_path))
		{
			add_sound_from_future(
				key,
				voice_count,
				Assets.loadAudioBuffer(targetted_asset_path)
			);
		}
		else
		{
			trace('no asset exists at path $targetted_asset_path');
		}
	}

	inline function warn_key(key: Int)
	{
		if (sounds.exists(key))
		{
			trace('warning: sound with key $key already exists');
		}
	}

	public function add_sound_from_future(key: Int, voice_count: Int, future: Future<AudioBuffer>)
	{
		warn_key(key);

		future.onComplete(buffer ->
		{
			sounds[key] = new Sound(buffer, voice_count, gain);
			trace('sound prepared: $key');
		});

		future.onError(error ->
		{
			trace('error preparing: $key ($error)');
		});

		future.onProgress((i1, i2) ->
		{
			trace('loading sound $key progress $i1 $i2');
		});
	}

	public function play_sound(key: Int, pitch: Float = 1.0)
	{
		if (sounds.exists(key))
		{
			sounds[key].play(pitch);
		}
		else
		{
			trace('no sound $key');
		}
	}

	public function sound_pan(key: Int, pan: Float)
	{
		if (sounds.exists(key))
		{
			sounds[key].pan = pan;
		}
	}

	public function sound_volume(key: Int, volume: Float)
	{
		if (sounds.exists(key))
		{
			sounds[key].volume = volume;
		}
	}

	public function fade_in_to_target(on_fade_complete: Void -> Void = null, fade_target: Float = 0.9, fade_amount_per_step: Float = 0.01)
	{
		this.on_fade_complete = on_fade_complete;
		this.fade_target = fade_target;
		this.fade_amount_per_step = fade_amount_per_step;

		is_fading_in = true;
		is_fading_out = false;
	}

	public function fade_out_to_target(on_fade_complete: Void -> Void = null, fade_target: Float = 0.0, fade_amount_per_step: Float = 0.01)
	{
		this.on_fade_complete = on_fade_complete;
		this.fade_target = fade_target;
		this.fade_amount_per_step = fade_amount_per_step;

		is_fading_out = true;
		is_fading_in = false;
	}

	public function update(elapsed_seconds:Float)
	{
		if (is_fading_out)
		{
			fade_out.update(elapsed_seconds);
			if (gain <= fade_target && on_fade_complete != null)
			{
				gain = fade_target;
				is_fading_out = false;
				on_fade_complete();
			}
		}

		if (is_fading_in)
		{
			fade_in.update(elapsed_seconds);
			if (gain >= fade_target)
			{
				gain = fade_target;
				is_fading_in = false;
			}
		}
	}

	public function dispose()
	{
		if (music != null)
		{
			music.stop();
		}
	}

	public function mute()
	{
		gain = 0;
		if (music != null)
		{
			music.gain = gain;
		}
	}

	public function reduce_gain(amount: Float = 0.2): Void
	{
		gain -= Math.max(fade_amount_per_step, amount);
		trace('reduce_gain $gain $_gain');
	}

	public function increase_gain(amount: Float = 0.2): Void
	{
		gain += Math.max(fade_amount_per_step, amount);
		trace('increase_gain $gain $_gain');
	}

	var on_fade_complete: Void -> Void;

	public function cleanUp() {}

	var _gain: Float = 0.9;

	public var gain(get, set): Float;

	function set_gain(value: Float): Float
	{
		_gain = value;
		if (_gain < 0)
		{
			_gain = 0;
		}
		if (_gain > 1)
		{
			_gain = 1;
		}
		if (music != null)
		{
			music.gain = _gain;
			// trace('set music gain $_gain');
		}
		for (sound in sounds)
		{
			@:privateAccess
			sound.gain = _gain;
		}
		return _gain;
	}

	function get_gain(): Float
	{
		return _gain;
	}

	public function music_pan(ratio: Float)
	{
		if (music != null)
		{
			music.position.x = ratio;
		}
	}
}

class Sound
{
	var voices: Vector<AudioSource>;
	var voice_is_playing: Vector<Bool>;

	/**
		sets volume on a range of 0 (silent) to 1 (loudest), secondary to the gain property
		values outside this range will be clamped
	**/
	public var volume(default, set): Float;

	/**
		sets panning on a range of -1 (left) to 1 (right), 0 is the center
		values outside this range will be clamped
	**/
	public var pan(default, set): Float;

	/**
		sets gain on a range of 0 (silent) to 1 (loudest), this is controlled by the SoundManager, see volume for setting the Sounds individual volume
		values outside this range will be clamped
	**/
	var gain(default, set): Float;

	public function new(buffer: AudioBuffer, voice_count: Int, gain: Float, offset: Int = 0)
	{
		voices = new Vector<AudioSource>(voice_count);
		voice_is_playing = new Vector<Bool>(voice_count);

		// var offset = 0;
		var length = null;
		var loops = 0;

		for (i in 0...voice_count)
		{
			voices[i] = new AudioSource(buffer, offset, length, loops);
		}

		this.gain = gain;
		volume = 1.0;
		pan = 0.0;
	}

	var onComplete: Void -> Void;

	public function play(pitch: Float)
	{
		for (i in 0...voices.length)
		{
			if (!voice_is_playing[i])
			{
				voices[i].pitch = pitch;
				voices[i].onComplete.add(() -> voice_is_playing[i] = false);
				voice_is_playing[i] = true;
				voices[i].play();
				break;
			}
		}
	}

	function set_gain(value: Float): Float
	{
		for (voice in voices)
		{
			voice.gain = value;
		}
		return value;
	}

	function set_volume(value: Float): Float
	{
		volume = value < 0 ? 0 : value > 1 ? 1 : value;

		for (voice in voices)
		{
			voice.position = new Vector4(pan, volume, volume);
		}

		return volume;
	}

	function set_pan(value: Float): Float
	{
		pan = value < -1 ? -1 : value > 1 ? 1 : value;
		for (voice in voices)
		{
			// voice.position.x = pan; // this value never makes it to the ALSource, it does work on HTML5 though
			// voice.position.setTo(pan, 0.0, 0.0); // similarly this value never makes it to the ALSource
			// the following works with the HTML5 audio backend and the OpenAL audio backend
			voice.position = new Vector4(pan, volume, volume);
		}
		return pan;
	}
}
