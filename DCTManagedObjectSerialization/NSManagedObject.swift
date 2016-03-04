
import CoreData

extension NSManagedObject {

	func set(value value: Value, attribute: NSAttributeDescription, serializationInfo: SerializationInfo) {

		switch value {

			case .None: break
			case .Some: break

			case .Nil:
				if serializationInfo.shouldDeserializeNilValues[entity] {
					setValue(nil, forKey: attribute.name)
				}

			case .One(let object):
				setValue(object, forKey: attribute.name)
		}
	}

	func set(value value: Value, relationship: NSRelationshipDescription, serializationInfo: SerializationInfo) {

		switch value {

			case .None: break

			case .Nil:
				if serializationInfo.shouldDeserializeNilValues[entity] {
					setValue(nil, forKey: relationship.name)
				}

			case .One(let object):
				if !relationship.toMany {
					setValue(object, forKey: relationship.name)
				}

			case .Some(let objects):
				if relationship.toMany {

					if serializationInfo.shouldBeUnion[relationship] {

						if relationship.ordered {
							let set = mutableOrderedSetValueForKey(relationship.name)
							set.addObjectsFromArray(objects)
						} else {
							let set = mutableSetValueForKey(relationship.name)
							set.addObjectsFromArray(objects)
						}

					} else {

						if relationship.ordered {
							setValue(NSOrderedSet(array: objects), forKey: relationship.name)
						} else {
							setValue(NSSet(array: objects), forKey: relationship.name)
						}
					}
				}
		}
	}
}
