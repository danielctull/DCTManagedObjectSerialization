
import Foundation
import CoreData

enum Value {
	case Some(AnyObject)
	case Nil
	case None
}

protocol ValueProperty {
	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> Value
}

extension NSAttributeDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> Value {

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]
		guard let serializedValue = serializedDictionary[serializationName] else {
			return .None
		}

		if serializedValue as? NSNull != nil {
			return .Nil
		}

		var transformedValue: AnyObject? = serializedValue
		let transformers = serializationInfo.transformers[self]
		for transformer in transformers {
			transformedValue = transformer.transformedValue(transformedValue)
		}

		guard let value = transformedValue else {
			return .None
		}

		let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(validationPredicates)
		guard predicate.evaluateWithObject(value) else {
			return .None
		}

		return Value.Some(value)
	}
}


extension NSRelationshipDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> Value {

		guard let destinationEntity = destinationEntity else {
			return .None
		}

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]

		guard let serializedValue = serializedDictionary[serializationName] else {
			return .None
		}

		if serializedValue as? NSNull != nil {
			return .Nil
		}

		var transformedValue: AnyObject? = serializedValue
		let transformers = serializationInfo.transformers[self]
		for transformer in transformers {
			transformedValue = transformer.transformedValue(transformedValue)
		}

		if toMany {

			guard let array = transformedValue as? SerializedArray else {
				return .None
			}

			let objects = deserializer.deserializeObjectsWithEntity(destinationEntity, array: array)

			if ordered {
				return Value.Some(NSOrderedSet(array: objects))
			} else {
				return Value.Some(NSSet(array: objects))
			}
		}

		guard let dictionary = transformedValue as? SerializedDictionary else {
			return .None
		}

		guard let value = deserializer.deserializeObjectWithEntity(destinationEntity, dictionary: dictionary) else {
			return .None
		}

		return Value.Some(value)
	}
}
