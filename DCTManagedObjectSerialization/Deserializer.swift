
import Foundation
import CoreData

public enum DeserializerError: ErrorType {
	case Unknown
}

typealias JSONDictionary = [ String : AnyObject ]

public struct Deserializer {

	public let managedObjectContext: NSManagedObjectContext
	public let serializationInfo: SerializationInfo
	init(managedObjectContext: NSManagedObjectContext, serializationInfo: SerializationInfo = SerializationInfo()) {
		self.managedObjectContext = managedObjectContext
		self.serializationInfo = serializationInfo
	}

	func deserializeObjectWithEntity(entity: NSEntityDescription, dictionary: JSONDictionary) -> AnyObject? {
		let objects = deserializeObjectsWithEntity(entity, array: [dictionary])
		return objects.first
	}

	func deserializeObjectsWithEntity(entity: NSEntityDescription, array: [JSONDictionary]) -> [AnyObject] {

		var objects: [AnyObject] = []
		for JSON in array {

			var object: NSManagedObject
			if let predicate = predicateForUniqueObjectWithEntity(entity, JSON: JSON) {
				object = existingObjectForEntity(entity, predicate: predicate)
			} else {
				object = objectForEntity(entity)
			}

			for property in entity.properties {
				let value = valueFromDictionary(JSON, forProperty: property)
				object.setValue(value, forKey: property.name)
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

	private func predicateForUniqueObjectWithEntity(entity: NSEntityDescription, JSON: JSONDictionary) -> NSPredicate? {

		let uniqueProperties = serializationInfo.uniqueProperties[entity]
		var predicates: [NSPredicate] = []
		for property in uniqueProperties {

			guard let value = valueFromDictionary(JSON, forProperty: property) else {
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

	private func valueFromDictionary(dictionary: JSONDictionary, forProperty property: NSPropertyDescription) -> AnyObject? {

		let serializationName = serializationInfo.serializationName[property]
		let transformers = serializationInfo.transformers[property]
		let serializedValue = dictionary[serializationName]

		var value: AnyObject? = serializedValue
		for transformer in transformers {
			value = transformer.transformedValue(value)
		}

		let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(property.validationPredicates)
		if predicate.evaluateWithObject(value) {
			return value
		}

		return nil
	}
}
