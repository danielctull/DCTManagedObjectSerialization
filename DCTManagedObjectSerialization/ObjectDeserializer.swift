
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

			print("Starting import of \(entity.name!).\(name)")

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

			print("Imported \(entity.name!).\(name) = \(self.object.valueForKey(name))")
		}

		let group = dispatch_group_create()
		for (name, relationship) in entity.relationshipsByName {

			print("Starting import of \(entity.name!).\(name)")
			dispatch_group_enter(group)
			relationship.valueForSerializedDictionary(serializedDictionary, deserializer: deserializer) { relationshipValue in

				self.managedObjectContext.performBlock {

					switch relationshipValue {

					case let .Many(objectIDs):

						print("MANY: \(objectIDs)")


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

					case let .One(value):
						self.object.setValue(value, forKey: name)

					case .Nil:
						if shouldDeserializeNilValues {
							self.object.setValue(nil, forKey: name)
						}

					case .None:
						break
					}

					print("Imported \(entity.name!).\(name) = \(self.object.valueForKey(name))")
					dispatch_group_leave(group)
				}
			}
		}

		dispatch_group_notify(group, dispatch_queue_create("ObjectDeserializer Callback", nil)) {
			print("NOTIFYING")
			self.managedObjectContext.performBlock {
				print("NOTIFYING2")

				if self.object.hasChanges {
					print("HAS CHANGES")
					do {
						print("SAVING")
						try self.managedObjectContext.save()
						try self.managedObjectContext.obtainPermanentIDsForObjects([self.object])
						print("SAVING DONE")
					} catch {}
				}

				completion(self.object.objectID)
			}
		}
	}
}
