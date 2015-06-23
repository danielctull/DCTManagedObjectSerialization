
import Foundation

struct Cache<Key: AnyObject, Value: AnyObject> {

	let cache = NSCache()

	subscript (key: Key) -> Value? {
		get {
			return cache.objectForKey(key) as? Value
		}
		set(newValue) {
			if let newValue = newValue {
				cache.setObject(newValue, forKey: key)
			} else {
				cache.removeObjectForKey(key)
			}
		}
	}
}
