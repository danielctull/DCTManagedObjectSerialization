
import Foundation
import CoreData

protocol ValueProperty {
	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> AnyObject?
}

extension NSAttributeDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> AnyObject? {

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]
		let transformers = serializationInfo.transformers[self]
		let serializedValue = serializedDictionary[serializationName]

		var value: AnyObject? = serializedValue
		for transformer in transformers {
			value = transformer.transformedValue(value)
		}

		let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(validationPredicates)
		guard predicate.evaluateWithObject(value) else {
			return nil
		}

		return value
	}
}


extension NSRelationshipDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> AnyObject? {

		guard let destinationEntity = destinationEntity else {
			return nil
		}

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]
		let transformers = serializationInfo.transformers[self]
		let serializedValue = serializedDictionary[serializationName]

		var value: AnyObject? = serializedValue
		for transformer in transformers {
			value = transformer.transformedValue(value)
		}

		if toMany {

			guard let array = value as? SerializedArray else {
				return nil
			}

			let objects = deserializer.deserializeObjectsWithEntity(destinationEntity, array: array)

			if ordered {
				return NSOrderedSet(array: objects)
			} else {
				return NSSet(array: objects)
			}
		}

		guard let dictionary = value as? SerializedDictionary else {
			return nil
		}

		return deserializer.deserializeObjectWithEntity(destinationEntity, dictionary: dictionary)
	}
}


