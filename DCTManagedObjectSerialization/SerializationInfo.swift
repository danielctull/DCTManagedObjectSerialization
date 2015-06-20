
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
	private var fallback: Key -> Value

	private init(userInfoKey: String, transformer: String -> Value, fallback: Key -> Value) {
		self.userInfoKey = userInfoKey
		self.transformer = transformer
		self.fallback = fallback
	}

	subscript (key: Key) -> Value {
		get {
			return valueForKey(key)
		}
		set(newValue) {
			setValue(newValue, forKey: key)
		}
	}

	public mutating func setValue(value: Value?, forKey key: Key) {
		values[key] = value
	}

	public func valueForKey(key: Key) -> Value {

		if let value = values[key] {
			return value
		}

		if let string = key.userInfo?[userInfoKey] as? String {
			return transformer(string)
		}

		return fallback(key)
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

	private static let stringToTransformers: String -> [NSValueTransformer] = { string in
		let noWhiteSpaceString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		let names = noWhiteSpaceString.componentsSeparatedByString(",")
		guard let transformers = (names.map { NSValueTransformer(forName: $0) }.filter { return $0 != nil }) as? [NSValueTransformer] else {
			return []
		}
		return transformers
	}

	public var uniqueKeys = SerializationInfoStorage<NSEntityDescription,[String]>(userInfoKey: UserInfoKeys.uniqueKeys, transformer: stringToArray, fallback: { entity in return [] })
	public var shouldDeserializeNilValues = SerializationInfoStorage<NSEntityDescription,Bool>(userInfoKey: UserInfoKeys.shouldDeserializeNilValues, transformer: stringToBool, fallback: { entity in return false })
	public var serializationName = SerializationInfoStorage<NSPropertyDescription,String>(userInfoKey: UserInfoKeys.serializationName, transformer: { $0 }, fallback: { $0.name })
	public var transformers = SerializationInfoStorage<NSPropertyDescription,[NSValueTransformer]>(userInfoKey: UserInfoKeys.transformerNames, transformer: stringToTransformers, fallback: { entity in return [] })
	public var shouldBeUnion = SerializationInfoStorage<NSRelationshipDescription,Bool>(userInfoKey: UserInfoKeys.shouldBeUnion, transformer: stringToBool, fallback: { entity in return false })
}
