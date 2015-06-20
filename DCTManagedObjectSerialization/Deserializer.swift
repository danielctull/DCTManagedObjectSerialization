
import Foundation
import CoreData

public enum DeserializerError: ErrorType {
	case Unknown
}

typealias JSONDictionary = [ String : AnyObject ]

public class Deserializer {
	public var info = SerializationInfo()
	public let managedObjectContext: NSManagedObjectContext
	public init(managedObjectContext: NSManagedObjectContext) {
		self.managedObjectContext = managedObjectContext
	}

//	- (NSArray *)deserializeObjectsWithEntity:(NSEntityDescription *)entity
//	fromArray:(NSArray *)array
//	existingObjectsPredicate:(NSPredicate *)existingObjectsPredicate


	func deserializeObjectWithEntity(entity: NSEntityDescription, dictionary: JSONDictionary) -> AnyObject? {
		let objects = deserializeObjectsWithEntity(entity, array: [dictionary])
		print(objects)
		return objects.first
	}

	func deserializeObjectsWithEntity(entity: NSEntityDescription, array: [JSONDictionary]) -> [AnyObject] {

		var objects: [AnyObject] = []
		for JSON in array {

			let predicate = predicateForUniqueObjectWithEntity(entity, JSON: JSON)
			let object = objectForEntity(entity, predicate: predicate)
			


			objects.append(object)
		}
		
		return objects
	}

	private func objectForEntity(entity: NSEntityDescription, predicate: NSPredicate?) -> NSManagedObject {

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
			return NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
		}
	}

	private func predicateForUniqueObjectWithEntity(entity: NSEntityDescription, JSON: JSONDictionary) -> NSPredicate? {

		let uniqueKeys = info.uniqueKeys[entity]
		var predicates: [NSPredicate] = []
		for uniqueKey in uniqueKeys {

			guard let property = entity.propertiesByName[uniqueKey] else {
				continue
			}

			guard let value = valueFromDictionary(JSON, forProperty: property) else {
				continue
			}

			let predicate = NSPredicate(format: "%K == %@", argumentArray: [uniqueKey, value])
			predicates.append(predicate)
		}

		return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
	}

	private func valueFromDictionary(dictionary: JSONDictionary, forProperty property: NSPropertyDescription) -> AnyObject? {

		let serializationName = info.serializationName[property]
		let transformers = info.transformers[property]
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

//
//
//
//
//- (NSPredicate *)predicateForUniqueObjectWithEntity:(NSEntityDescription *)entity
//dictionary:(NSDictionary *)dictionary
//managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
//
//	NSArray *uniqueKeys = [self uniqueKeysForEntity:entity];
//	if (uniqueKeys.count == 0) return nil;
//	NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:uniqueKeys.count];
//	[uniqueKeys enumerateObjectsUsingBlock:^(NSString *uniqueKey, NSUInteger i, BOOL *stop) {
//
//		NSPropertyDescription *property = [entity.propertiesByName objectForKey:uniqueKey];
//
//		NSAssert(property != nil, @"A unique key has been set that doesn't exist.");
//
//		NSString *serializationName = [self serializationNameForProperty:property];
//		id serializationValue = [dictionary valueForKeyPath:serializationName];
//		id value = [property dct_valueForSerializedValue:serializationValue withDeserializer:self];
//		if (!value) return;
//		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, value];
//		[predicates addObject:predicate];
//		}];
//	if (predicates.count == 0) return nil;
//	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
//}