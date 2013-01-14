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


	_dictionary = dictionary;
	_entity = entity;
	_managedObjectContext = managedObjectContext;

	NSManagedObject *managedObject = [self existingObjectWithDictionary:dictionary
																 entity:entity
												   managedObjectContext:managedObjectContext];

	if (!managedObject)
		managedObject = [[NSManagedObject alloc] initWithEntity:_entity insertIntoManagedObjectContext:_managedObjectContext];

	[managedObject dct_awakeFromSerializedRepresentation:_dictionary];

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

		NSString *serializationName = [self _serializationNameForPropertyName:uniqueKey];
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

- (NSString *)_serializationNameForPropertyName:(NSString *)propertyName {
	NSPropertyDescription *property = [[_entity propertiesByName] objectForKey:propertyName];
	return property.dct_serializationName;
}

- (NSString *)_propertyNameForSerializationName:(NSString *)serializationName {
	NSString *propertyName = [[self _serializationNameToPropertyNameMapping] objectForKey:serializationName];

	if (propertyName.length == 0 && [[[_entity propertiesByName] allKeys] containsObject:serializationName])
		propertyName = serializationName;

	return propertyName;
}

- (NSDictionary *)_serializationNameToPropertyNameMapping {

	if (!_serializationNameToPropertyNameMapping) {
		NSArray *properties = _entity.properties;
		NSMutableDictionary *serializationNameToPropertyNameMapping = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
		[properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {
			[serializationNameToPropertyNameMapping setObject:property.name forKey:property.dct_serializationName];
		}];
		_serializationNameToPropertyNameMapping = [serializationNameToPropertyNameMapping copy];
	}

	return _serializationNameToPropertyNameMapping;
}

@end
