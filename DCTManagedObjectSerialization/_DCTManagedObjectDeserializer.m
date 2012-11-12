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

- (id)initWithDictionary:(NSDictionary *)dictionary
				  entity:(NSEntityDescription *)entity
	managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	self = [self init];
	if (!self) return nil;
	_dictionary = dictionary;
	_entity = entity;
	_managedObjectContext = managedObjectContext;
	return self;
}

- (id)deserializedObject {

	NSManagedObject *managedObject = [self _existingObject];

	if (!managedObject)
		managedObject = [[NSManagedObject alloc] initWithEntity:_entity insertIntoManagedObjectContext:_managedObjectContext];

	[self _setupManagedObject:managedObject];

	return managedObject;
}

- (void)_setupManagedObject:(NSManagedObject *)managedObject {
	NSEntityDescription *entity = managedObject.entity;

	[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {

		NSString *propertyName = property.name;
		NSString *serializationName = [self _serializationNameForPropertyName:propertyName];
		id serializedValue = [_dictionary objectForKey:serializationName];

		if (serializedValue || entity.dct_shouldDeserializeNilValues)
			[managedObject dct_setSerializedValue:serializedValue forKey:propertyName];
	}];
}

- (NSManagedObject *)_existingObject {
	NSPredicate *predicate = [self _uniqueKeysPredicate];
	if (!predicate) return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:_entity.name];
	fetchRequest.predicate = predicate;
	NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	return [result lastObject];
}

- (NSPredicate *)_uniqueKeysPredicate {
	NSArray *uniqueKeys = _entity.dct_serializationUniqueKeys;
	if (uniqueKeys.count == 0) return nil;
	NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:uniqueKeys.count];
	[uniqueKeys enumerateObjectsUsingBlock:^(NSString *uniqueKey, NSUInteger i, BOOL *stop) {

		NSPropertyDescription *property = [_entity.propertiesByName objectForKey:uniqueKey];

		NSAssert(property != nil, @"A unique key has been set that doesn't exist.");

		NSString *serializationName = [self _serializationNameForPropertyName:uniqueKey];
		id serializedValue = [_dictionary objectForKey:serializationName];
		id value = [property dct_valueForSerializedValue:serializedValue inManagedObjectContext:_managedObjectContext];
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
