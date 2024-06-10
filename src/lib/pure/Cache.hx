package lib.pure;

@:structInit
class Cache<T> {
	public var cached_items:Array<Cached<T>> = [];

	var create:Void->T;
	var cache:T->Void;
	var item_limit:Int;

	public function get():Null<T> {
		for (cached in cached_items) {
			if (cached.is_waiting) {
				cached.is_waiting = false;
				return cached.item;
			}
		}

		if (cached_items.length < item_limit) {
			var cached:Cached<T> = {
				item: create(),
				is_waiting: false
			}
			cached_items.push(cached);
			return cached.item;
		}

		return null;
	}

	inline function re_cache(cached:Cached<T>) {
		cache(cached.item);
		cached.is_waiting = true;
	}

	public function put(item:T) {
		for (cached in cached_items) {
			if (cached.item == item) {
				re_cache(cached);
				break;
			}
		}
	}

	public function cache_all() {
		for (cached in cached_items) {
			re_cache(cached);
		}
	}
}

@:structInit
@:publicFields
class Cached<T> {
	var item:T;
	var is_waiting:Bool;
}
