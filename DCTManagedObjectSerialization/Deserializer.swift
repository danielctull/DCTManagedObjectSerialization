
import Foundation
import CoreData

public enum DeserializerError: ErrorType {
	case Unknown
}

typealias SerializedDictionary = [ String : AnyObject ]
typealias SerializedArray = [ SerializedDictionary ]

public struct Deserializer {

	public let managedObjectContext: NSManagedObjectContext
	public let serializationInfo: SerializationInfo
	init(managedObjectContext: NSManagedObjectContext, serializationInfo: SerializationInfo = SerializationInfo()) {
		self.managedObjectContext = managedObjectContext
		self.serializationInfo = serializationInfo
	}

	func deserializeObjectWithEntity(entity: NSEntityDescription, dictionary: SerializedDictionary) -> AnyObject? {
		let objects = deserializeObjectsWithEntity(entity, array: [dictionary])
		return objects.first
	}

	func deserializeObjectsWithEntity(entity: NSEntityDescription, array: SerializedArray) -> [AnyObject] {

		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]
		var objects: [AnyObject] = []
		for serializedDictionary in array {

			var object: NSManagedObject
			if let predicate = predicateForUniqueObjectWithEntity(entity, serializedDictionary: serializedDictionary) {
				object = existingObjectForEntity(entity, predicate: predicate)
			} else {
				object = objectForEntity(entity)
			}

			for property in entity.properties {

				guard let valueProperty = property as? ValueProperty else {
					continue
				}

				let value = valueProperty.valueForSerializedDictionary(serializedDictionary, deserializer: self)
				switch value {

				case let .Some(v):
					object.setValue(v, forKey: property.name)

				case .Nil:
					if shouldDeserializeNilValues {
						object.setValue(nil, forKey: property.name)
					}

				case .None:
					break
				}
			}

			objects.append(object)
		}
		
		return objects
	}

	private func existingObjectForEntity(entity: NSEntityDescription, predicate: NSPredicate) -> NSManagedObject {

		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = entity
		fetchRequest.predicate = predicate

		do {
			let results = try managedObjectContext.executeFetchRequest(fetchRequest)
			guard let object = results.first as? NSManagedObject else {
				throw DeserializerError.Unknown
			}
			return object

		} catch {
			return objectForEntity(entity)
		}
	}

	private func objectForEntity(entity: NSEntityDescription) -> NSManagedObject {
		return NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}

	private func predicateForUniqueObjectWithEntity(entity: NSEntityDescription, serializedDictionary: SerializedDictionary) -> NSPredicate? {

		let uniqueProperties = serializationInfo.uniqueProperties[entity]
		var predicates: [NSPredicate] = []
		for property in uniqueProperties {

			guard let valueProperty = property as? ValueProperty else {
				continue
			}

			guard let value = valueProperty.valueForSerializedDictionary(serializedDictionary, deserializer: self) else {
				continue
			}

			let predicate = NSPredicate(format: "%K == %@", argumentArray: [property.name, value])
			predicates.append(predicate)
		}

		guard predicates.count > 0 else {
			return nil
		}

		return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
	}
}
