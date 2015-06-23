
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

	public func deserializeObjectWithEntity(entity: NSEntityDescription, dictionary: SerializedDictionary, completion: NSManagedObject? -> Void) {
		deserializeObjectsWithEntity(entity, array: [dictionary]) { objects in
			completion(objects.first)
		}
	}

	public func deserializeObjectsWithEntity(entity: NSEntityDescription, array: SerializedArray, completion: [NSManagedObject] -> Void) {
		deserializeObjectIDsWithEntity(entity, array: array) { objectIDs in
			self.managedObjectContext.performBlock {
				let managedObjects = objectIDs.map { self.managedObjectContext.objectWithID($0) }
				completion(managedObjects)
			}
		}
	}

	func deserializeObjectIDWithEntity(entity: NSEntityDescription, dictionary: SerializedDictionary, completion: NSManagedObjectID? -> Void) {
		deserializeObjectIDsWithEntity(entity, array: [dictionary]) { objectIDs in
			completion(objectIDs.first)
		}
	}

	func deserializeObjectIDsWithEntity(entity: NSEntityDescription, array: SerializedArray, completion: [NSManagedObjectID] -> Void) {
		managedObjectContext.performBlock {
			let deserializer = self.deserializerForEntity(entity)
			deserializer.deserializeObjectsFromArray(array, deserializer: self) { objectIDs in
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

	private var deserializers = Cache<NSEntityDescription, EntityDeserializer>()
	private func deserializerForEntity(entity: NSEntityDescription) -> EntityDeserializer {

		if let deserializer = deserializers[entity] {
			return deserializer
		}

		let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		moc.parentContext = managedObjectContext
		let deserializer = EntityDeserializer(managedObjectContext: moc, entity: entity, serializationInfo: serializationInfo)
		deserializers[entity] = deserializer
		return deserializer
	}
}
