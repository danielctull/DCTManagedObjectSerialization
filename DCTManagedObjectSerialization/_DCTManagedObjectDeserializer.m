//
//  _DCTManagedObjectDeserializer.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTManagedObjectDeserializer.h"
#import "DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"
#import "NSManagedObject+DCTManagedObjectSerialization.h"

@implementation _DCTManagedObjectDeserializer

- (id)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
	self = [self init];
	if (!self) return nil;
	_managedObjectModel = managedObjectModel;
	return self;
}

- (id)deserializedObjectFromDictionary:(NSDictionary *)dictionary
							rootEntity:(NSEntityDescription *)entity
				  managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	NSManagedObject *managedObject = [self existingObjectWithDictionary:dictionary
																 entity:entity
												   managedObjectContext:managedObjectContext];

	if (!managedObject)
		managedObject = [[NSManagedObject alloc] initWithEntity:entity
								 insertIntoManagedObjectContext:managedObjectContext];

	[managedObject dct_awakeFromSerializedRepresentation:dictionary];

	return managedObject;
}

- (NSManagedObject *)existingObjectWithDictionary:(NSDictionary *)dictionary
										   entity:(NSEntityDescription *)entity
							 managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSPredicate *predicate = [self predicateForUniqueObjectWithEntity:entity
														   dictionary:dictionary
												 managedObjectContext:managedObjectContext];
	if (!predicate) return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entity.name];
	fetchRequest.predicate = predicate;
	NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	return [result lastObject];
}

- (NSPredicate *)predicateForUniqueObjectWithEntity:(NSEntityDescription *)entity
										 dictionary:(NSDictionary *)dictionary
							   managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSArray *uniqueKeys = entity.dct_serializationUniqueKeys;
	if (uniqueKeys.count == 0) return nil;
	NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:uniqueKeys.count];
	[uniqueKeys enumerateObjectsUsingBlock:^(NSString *uniqueKey, NSUInteger i, BOOL *stop) {

		NSPropertyDescription *property = [entity.propertiesByName objectForKey:uniqueKey];

		NSAssert(property != nil, @"A unique key has been set that doesn't exist.");

		NSString *serializationName = [self serializationNameForPropertyName:uniqueKey entity:entity];
		id serializedValue = [dictionary objectForKey:serializationName];
		id value = [property dct_valueForSerializedValue:serializedValue inManagedObjectContext:managedObjectContext];
		if (!value) return;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, value];
		[predicates addObject:predicate];
	}];
	if (predicates.count == 0) return nil;
	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

#pragma mark -

- (NSString *)serializationNameForPropertyName:(NSString *)propertyName
										entity:(NSEntityDescription *)entity {
	NSPropertyDescription *property = [[entity propertiesByName] objectForKey:propertyName];
	return property.dct_serializationName;
}

@end
