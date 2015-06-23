
import Foundation
import CoreData

enum RelationshipValue: CustomStringConvertible {
	case Many([NSManagedObjectID])
	case One(NSManagedObjectID)
	case Nil
	case None

	var description: String {

		switch self {

		case let .One(objectID):
			return "RelationshipValue.One(\(objectID))"

		case let .Many(objectIDs):
			return "RelationshipValue.Many(\(objectIDs))"

		case .Nil:
			return "RelationshipValue.Nil"

		case .None:
			return "RelationshipValue.None"
		}
	}
}

extension NSRelationshipDescription {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, deserializer: Deserializer, completion: RelationshipValue -> Void) {

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

			deserializer.deserializeObjectIDsWithEntity(destinationEntity, array: array) { objectIDs in
				completion(.Many(objectIDs))
			}
		}

		guard let dictionary = transformedValue as? SerializedDictionary else {
			completion(.None)
			return
		}

		deserializer.deserializeObjectIDWithEntity(destinationEntity, dictionary: dictionary) { objectID in

			guard let objectID = objectID else {
				completion(.None)
				return
			}

			completion(.One(objectID))
		}
	}
}
