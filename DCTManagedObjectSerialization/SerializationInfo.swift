
import Foundation
import CoreData

// Allow for a key to be any of the types we require - NSEntityDescription, NSPropertyDescription et al
public protocol SerializationInfoStorageKey: Hashable {
	var userInfo: [NSObject : AnyObject]? { get }
}
extension NSEntityDescription: SerializationInfoStorageKey {}
extension NSPropertyDescription: SerializationInfoStorageKey {}

public struct SerializationInfoStorage<Key: SerializationInfoStorageKey, Value> {

	private var values: [ Key : Value ] = [:]

	private let userInfoKey: String
	private let transformer: String -> Value
	private var fallback: (Key -> Value)?

	private init(userInfoKey: String, transformer: String -> Value) {
		self.init(userInfoKey: userInfoKey, transformer: transformer, fallback: nil)
	}

	private init(userInfoKey: String, transformer: String -> Value, fallback: (Key -> Value)?) {
		self.userInfoKey = userInfoKey
		self.transformer = transformer
		self.fallback = fallback
	}

	public mutating func setValue(value: Value, forKey key: Key) {
		values[key] = value
	}

	public mutating func valueForKey(key: Key) -> Value? {

		if let value = values[key] {
			return value
		}

		if let string = key.userInfo?[userInfoKey] as? String {
			let value = transformer(string)
			values[key] = value
			return value
		}

		if let fallback = fallback {
			return fallback(key)
		}

		return nil
	}
}

public struct SerializationInfo {

	private struct UserInfoKeys {
		static let uniqueKeys = "uniqueKeys"
		static let shouldDeserializeNilValues = "shouldDeserializeNilValues"
		static let serializationName = "serializationName"
		static let transformerNames = "transformerNames"
		static let shouldBeUnion = "shouldBeUnion"
	}

	private static let stringToBool: String -> Bool = { string in
		return (string as NSString).boolValue
	}

	private static let stringToArray: String -> [String] = { string in
		let noWhiteSpaceString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		return noWhiteSpaceString.componentsSeparatedByString(",")
	}

	var uniqueKeys = SerializationInfoStorage<NSEntityDescription,[String]>(userInfoKey: UserInfoKeys.uniqueKeys, transformer: stringToArray)
	var shouldDeserializeNilValues = SerializationInfoStorage<NSEntityDescription,Bool>(userInfoKey: UserInfoKeys.shouldDeserializeNilValues, transformer: stringToBool, fallback: { entity in return false })
	var serializationName = SerializationInfoStorage<NSPropertyDescription,String>(userInfoKey: UserInfoKeys.serializationName, transformer: { $0 }, fallback: { $0.name })
	var transformerNames = SerializationInfoStorage<NSPropertyDescription,[String]>(userInfoKey: UserInfoKeys.transformerNames, transformer: stringToArray)
	var shouldBeUnion = SerializationInfoStorage<NSRelationshipDescription,Bool>(userInfoKey: UserInfoKeys.shouldBeUnion, transformer: stringToBool, fallback: { entity in return false })
}
