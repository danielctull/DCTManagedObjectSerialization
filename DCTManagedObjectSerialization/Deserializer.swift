
import Foundation
import CoreData

public enum DeserializerError: ErrorType {
	case Unknown
}

public typealias SerializedDictionary = [ String : AnyObject ]
public typealias SerializedArray = [ SerializedDictionary ]

public class Deserializer {

	public let managedObjectContext: NSManagedObjectContext
	public let serializationInfo: SerializationInfo
	public init(managedObjectContext: NSManagedObjectContext, serializationInfo: SerializationInfo = SerializationInfo()) {
		self.managedObjectContext = managedObjectContext
		self.serializationInfo = serializationInfo
	}

	public func deserializeObjectWithEntity(entity: NSEntityDescription, dictionary: SerializedDictionary, completion: AnyObject? -> Void) {
		deserializeObjectsWithEntity(entity, array: [dictionary]) { objects in
			completion(objects.first)
		}
	}

	public func deserializeObjectsWithEntity(entity: NSEntityDescription, array: SerializedArray, completion: [AnyObject] -> Void) {

		managedObjectContext.performBlock {

			let shouldDeserializeNilValues = self.serializationInfo.shouldDeserializeNilValues[entity]
			var objects: [AnyObject] = []
			for serializedDictionary in array {

				self.predicateForUniqueObjectWithEntity(entity, serializedDictionary: serializedDictionary) { predicate in

					var object: NSManagedObject
					if let p = predicate {
						object = self.existingObjectForEntity(entity, predicate: p)
					} else {
						object = self.objectForEntity(entity)
					}

					for property in entity.properties {

						guard let valueProperty = property as? ValueProperty else {
							continue
						}

						valueProperty.valueForSerializedDictionary(serializedDictionary, deserializer: self) { value in

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
					}
					
					objects.append(object)
				}
			}

			completion(objects)
		}
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

	private func predicateForUniqueObjectWithEntity(entity: NSEntityDescription, serializedDictionary: SerializedDictionary, completion: NSPredicate? -> Void) {

		let uniqueAttributes = serializationInfo.uniqueAttributes[entity]
		var predicates: [NSPredicate] = []
		for attribute in uniqueAttributes {

			attribute.valueForSerializedDictionary(serializedDictionary, deserializer: self) { value in

				switch value {

				case let .Some(v):
					let predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute.name, v])
					predicates.append(predicate)

				case .Nil:
					break

				case .None:
					break
				}


			}
		}

		guard predicates.count > 0 else {
			completion(nil)
			return
		}

		completion(NSCompoundPredicate.andPredicateWithSubpredicates(predicates))
		return
	}
}
