
import Foundation
import CoreData

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
		return objects.first
	}

	func deserializeObjectsWithEntity(entity: NSEntityDescription, array: [JSONDictionary]) -> [AnyObject] {

		for JSON in array {

			let predicate = predicateForUniqueObjectWithEntity(entity, JSON: JSON, managedObjectContext: managedObjectContext)
			

		}
		
		return []
	}




	private func predicateForUniqueObjectWithEntity(entity: NSEntityDescription, JSON: JSONDictionary, managedObjectContext: NSManagedObjectContext) -> NSPredicate? {

		guard let uniqueKeys = info.uniqueKeys[entity] else {
			return nil
		}

		var predicates: [NSPredicate] = []
		for uniqueKey in uniqueKeys {

			guard let property = entity.propertiesByName[uniqueKey],
			  serializationKey = info.serializationName[property],
			  transformerNames = info.transformerNames[property] else {

				break
			}

			guard let transformers = (transformerNames.map { NSValueTransformer(forName: $0) }) as? [NSValueTransformer] else {
				break
			}

			guard let value = valueFromDictionary(JSON, forProperty: property, serializationKey: serializationKey, transformers: transformers) else {
				break
			}

			let predicate = NSPredicate(format: "%K == %@", argumentArray: [uniqueKey, value])
			predicates.append(predicate)
		}

		return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
	}


	private func valueFromDictionary(dictionary: JSONDictionary, forProperty property: NSPropertyDescription, serializationKey: String, transformers: [NSValueTransformer]) -> AnyObject? {

		guard let serializedValue = dictionary[serializationKey] else {
			return nil
		}

		var value: AnyObject? = serializedValue
		for transformer in transformers {
			value = transformer.transformedValue(value)
		}

		return value
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