
import Foundation
import CoreData

enum Value {
	case Some(AnyObject)
	case Nil
	case None
}

protocol ValueProperty {
	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer, completion: Value -> Void)
}

extension NSAttributeDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer, completion: Value -> Void) {

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]
		guard let serializedValue = serializedDictionary[serializationName] else {
			completion(.None)
			return
		}

		if serializedValue as? NSNull != nil {
			completion(.Nil)
			return
		}

		var transformedValue: AnyObject? = serializedValue
		let transformers = serializationInfo.transformers[self]
		for transformer in transformers {
			transformedValue = transformer.transformedValue(transformedValue)
		}

		guard let value = transformedValue else {
			completion(.None)
			return
		}

		let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(validationPredicates)
		guard predicate.evaluateWithObject(value) else {
			completion(.None)
			return
		}

		completion(.Some(value))
	}
}


extension NSRelationshipDescription: ValueProperty {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer, completion: Value -> Void) {

		guard let destinationEntity = destinationEntity else {
			completion(.None)
			return
		}

		let serializationInfo = deserializer.serializationInfo
		let serializationName = serializationInfo.serializationName[self]

		guard let serializedValue = serializedDictionary[serializationName] else {
			completion(.None)
			return
		}

		if serializedValue as? NSNull != nil {
			completion(.Nil)
			return
		}

		var transformedValue: AnyObject? = serializedValue
		let transformers = serializationInfo.transformers[self]
		for transformer in transformers {
			transformedValue = transformer.transformedValue(transformedValue)
		}

		if toMany {

			guard let array = transformedValue as? SerializedArray else {
				completion(.None)
				return
			}

			deserializer.deserializeObjectsWithEntity(destinationEntity, array: array) { objects in
				if self.ordered {
					completion(Value.Some(NSOrderedSet(array: objects)))
				} else {
					completion(Value.Some(NSSet(array: objects)))
				}
			}
		}

		guard let dictionary = transformedValue as? SerializedDictionary else {
			completion(.None)
			return
		}

		deserializer.deserializeObjectWithEntity(destinationEntity, dictionary: dictionary) { object in

			guard let value = object else {
				completion(.None)
				return
			}

			completion(.Some(value))
		}
	}
}
