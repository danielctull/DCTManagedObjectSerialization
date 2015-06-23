
import Foundation
import CoreData


class ObjectDeserializer {

	let serializationInfo: SerializationInfo
	let object: NSManagedObject
	let managedObjectContext: NSManagedObjectContext

	init(managedObjectContext: NSManagedObjectContext, object: NSManagedObject, serializationInfo: SerializationInfo = SerializationInfo()) {
		self.managedObjectContext = managedObjectContext
		self.object = object
		self.serializationInfo = serializationInfo
	}

	func deserializeObject(dictionary: SerializedDictionary, deserializer: Deserializer, completion: NSManagedObjectID? -> Void) {

		managedObjectContext.performBlock {
			self._deserializeObject(dictionary, deserializer: deserializer, completion: completion)
		}
	}

	func _deserializeObject(serializedDictionary: SerializedDictionary, deserializer: Deserializer, completion: NSManagedObjectID? -> Void) {

		let entity = object.entity
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]

		for (name, attribute) in entity.attributesByName {

			let attributeValue = attribute.valueForSerializedDictionary(serializedDictionary, serializationInfo: serializationInfo)

			switch attributeValue {

			case let .One(value):
				object.setValue(value, forKey: name)

			case .Nil:
				if shouldDeserializeNilValues {
					object.setValue(nil, forKey: name)
				}

			case .None:
				break
			}
		}

		let group = dispatch_group_create()
		for (name, relationship) in entity.relationshipsByName {

			dispatch_group_enter(group)
			relationship.valueForSerializedDictionary(serializedDictionary, deserializer: deserializer) { relationshipValue in

				self.managedObjectContext.performBlock {

					switch relationshipValue {

					case let .Many(objectIDs):
						let managedObjects = objectIDs.map { self.managedObjectContext.objectWithID($0) }
						if self.serializationInfo.shouldBeUnion[relationship] {
							if relationship.ordered {
								let set = self.object.mutableOrderedSetValueForKey(name)
								set.addObjectsFromArray(managedObjects)
							} else {
								let set = self.object.mutableSetValueForKey(name)
								set.addObjectsFromArray(managedObjects)
							}
						} else {
							if relationship.ordered {
								self.object.setValue(NSOrderedSet(array: managedObjects), forKey: name)
							} else {
								self.object.setValue(NSSet(array: managedObjects), forKey: name)
							}
						}

					case let .One(objectID):
						let managedObject = self.managedObjectContext.objectWithID(objectID)
						self.object.setValue(managedObject, forKey: name)

					case .Nil:
						if shouldDeserializeNilValues {
							self.object.setValue(nil, forKey: name)
						}

					case .None:
						break
					}

					dispatch_group_leave(group)
				}
			}
		}

		dispatch_group_notify(group, dispatch_queue_create("ObjectDeserializer Callback", nil)) {
			self.managedObjectContext.performBlock {
				if self.managedObjectContext.hasChanges {
					do {
						try self.managedObjectContext.save()
						try self.managedObjectContext.obtainPermanentIDsForObjects([self.object])
					} catch {}
				}

				completion(self.object.objectID)
			}
		}
	}
}
