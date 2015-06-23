
import Foundation
import CoreData

class EntityDeserializer {

	let managedObjectContext: NSManagedObjectContext
	let entity: NSEntityDescription
	let serializationInfo: SerializationInfo


	init(managedObjectContext: NSManagedObjectContext, entity: NSEntityDescription, serializationInfo: SerializationInfo = SerializationInfo()) {
		self.managedObjectContext = managedObjectContext
		self.entity = entity
		self.serializationInfo = serializationInfo
	}

	func deserializeObjectsFromArray(array: SerializedArray, deserializer: Deserializer, completion: [NSManagedObjectID] -> Void) {
		managedObjectContext.performBlock {

			let group = dispatch_group_create()
			var objectIDs: [NSManagedObjectID] = []

			for serializedDictionary in array {

				dispatch_group_enter(group)

				let objectDeserializer = self.deserializerForSerializedDictionary(serializedDictionary)
				objectDeserializer.deserializeObject(serializedDictionary, deserializer: deserializer) { objectID in

					self.managedObjectContext.performBlock {

						if let objectID = objectID {
							objectIDs.append(objectID)
						}

						dispatch_group_leave(group)
					}
				}
			}

			dispatch_group_notify(group, dispatch_queue_create("Deserializer-Callback", nil)) {
				self.managedObjectContext.performBlock {

					if self.managedObjectContext.hasChanges {
						do {
							try self.managedObjectContext.save()
						} catch {}
					}

					completion(objectIDs)
				}
			}
		}
	}

	private func deserializerForSerializedDictionary(serializedDictionary: SerializedDictionary) -> ObjectDeserializer {

		if let predicate = predicateForUniqueObjectWithDictionary(serializedDictionary) {
			return deserializerForPredicate(predicate)
		}

		let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		moc.parentContext = managedObjectContext
		let object = objectForEntity(entity, managedObjectContext: moc)
		return ObjectDeserializer(managedObjectContext: moc, object: object, serializationInfo: serializationInfo)
	}

	private var deserializers = Cache<NSPredicate, ObjectDeserializer>()
	private func deserializerForPredicate(predicate: NSPredicate) -> ObjectDeserializer {

		if let deserializer = deserializers[predicate] {
			return deserializer
		}

		let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		moc.parentContext = managedObjectContext
		let object = objectForEntity(entity, managedObjectContext: moc, predicate: predicate)
		let deserializer = ObjectDeserializer(managedObjectContext: moc, object: object, serializationInfo: serializationInfo)
		deserializers[predicate] = deserializer
		return deserializer
	}

	private func objectForEntity(entity: NSEntityDescription, managedObjectContext: NSManagedObjectContext) -> NSManagedObject {
		return NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}

	private func objectForEntity(entity: NSEntityDescription, managedObjectContext: NSManagedObjectContext, predicate: NSPredicate) -> NSManagedObject {

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
			return objectForEntity(entity, managedObjectContext: managedObjectContext)
		}
	}

	private func predicateForUniqueObjectWithDictionary(serializedDictionary: SerializedDictionary) -> NSPredicate? {

		let uniqueAttributes = serializationInfo.uniqueAttributes[entity]
		var predicates: [NSPredicate] = []
		for attribute in uniqueAttributes {

			let attributeValue = attribute.valueForSerializedDictionary(serializedDictionary, serializationInfo: self.serializationInfo)

			switch attributeValue {

			case let .One(value):
				let predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute.name, value])
				predicates.append(predicate)

			case .Nil:
				break

			case .None:
				break
			}
		}

		guard predicates.count > 0 else {
			return nil
		}

		return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
	}
}
