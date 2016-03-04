
import Foundation
import CoreData

extension NSRelationshipDescription {

	func value(serializedDictionary serializedDictionary: SerializedDictionary, deserializer: Deserializer) -> Value {

		// If there is no detination entity return .None
		guard let destinationEntity = destinationEntity else {
			return .None
		}

		let value = transformedValue(serializedDictionary: serializedDictionary, serializationInfo: deserializer.serializationInfo)

		switch value {
			case .Nil: return .Nil
			case .None: return .None

			case .Some(let objects):

				guard
					let array = objects as? SerializedArray
					where toMany
				else {
					return .None
				}

				let objects = deserializer.deserialize(entity: destinationEntity, array: array)
				return .Some(objects)

			case .One(let object):

				guard
					let dictionary = object as? SerializedDictionary
					where !toMany,
					let object = deserializer.deserialize(entity: destinationEntity, dictionary: dictionary)
				else {
					return .None
				}

				return .One(object)
		}
	}
}
