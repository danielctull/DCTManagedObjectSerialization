
import CoreData

extension NSManagedObjectContext {

	func object(entity entity: NSEntityDescription, predicate: NSPredicate) -> NSManagedObject {

		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = entity
		fetchRequest.predicate = predicate
		fetchRequest.fetchLimit = 1

		do {
			let results = try executeFetchRequest(fetchRequest)
			guard let object = results.first as? NSManagedObject else {
				throw DeserializerError.Unknown
			}
			return object

		} catch {
			return object(entity: entity)
		}
	}

	func object(entity entity: NSEntityDescription) -> NSManagedObject {
		return NSManagedObject(entity: entity, insertIntoManagedObjectContext: self)
	}
}
