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
	_uniqueKeysByEntity = [NSMutableDictionary new];
	_shouldDeserializeNilValuesByEntity = [NSMutableDictionary new];
	_serializationNamesByProperty = [NSMutableDictionary new];
	_transformerNamesByAttribute = [NSMutableDictionary new];
	_serializationShouldBeUnionByRelationship = [NSMutableDictionary new];
	_managedObjectModel = managedObjectModel;
	NSArray *entities = [managedObjectModel entities];
	[entities enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger i, BOOL *stop) {

		[self setUniqueKeys:entity.dct_serializationUniqueKeys forEntity:entity];
		[self setShouldDeserializeNilValues:entity.dct_shouldDeserializeNilValues forEntity:entity];

		[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {

			[self setSerializationName:property.dct_serializationName forProperty:property];

			if ([property isKindOfClass:[NSAttributeDescription class]]) {
				NSAttributeDescription *attribute = (NSAttributeDescription *)property;
				[self setTransformerNames:attribute.dct_serializationTransformerNames forAttibute:attribute];
			}

			if ([property isKindOfClass:[NSRelationshipDescription class]]) {
				NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
				[self setSerializationShouldBeUnion:relationship.dct_serializationShouldBeUnion forRelationship:relationship];
			}
		}];
	}];

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

	[self setupManagedObject:managedObject withDictionary:dictionary];
	[managedObject dct_awakeFromSerializedRepresentation:dictionary];
	return managedObject;
}

- (void)setupManagedObject:(NSManagedObject *)managedObject
			withDictionary:(id)serializedRepresentation {
	
	NSEntityDescription *entity = managedObject.entity;
	[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {

		NSString *serializationName = [self serializationNameForProperty:property];
		id serializedValue = [serializedRepresentation valueForKeyPath:serializationName];

		if (serializedValue || [self shouldDeserializeNilValuesForEntity:entity])
			[managedObject dct_setSerializedValue:serializedValue forKey:property.name];
	}];
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
	
	NSArray *uniqueKeys = [self uniqueKeysForEntity:entity];
	if (uniqueKeys.count == 0) return nil;
	NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:uniqueKeys.count];
	[uniqueKeys enumerateObjectsUsingBlock:^(NSString *uniqueKey, NSUInteger i, BOOL *stop) {

		NSPropertyDescription *property = [entity.propertiesByName objectForKey:uniqueKey];

		NSAssert(property != nil, @"A unique key has been set that doesn't exist.");

		NSString *serializationName = [self serializationNameForProperty:property];

		id serializedValue = [dictionary objectForKey:serializationName];
		id value = [property dct_valueForSerializedValue:serializedValue inManagedObjectContext:managedObjectContext];
		if (!value) return;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, value];
		[predicates addObject:predicate];
	}];
	if (predicates.count == 0) return nil;
	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

#pragma mark - Setters/Getters

- (NSArray *)uniqueKeysForEntity:(NSEntityDescription *)entity {
	return [_uniqueKeysByEntity objectForKey:entity];
}

- (void)setUniqueKeys:(NSArray *)keys forEntity:(NSEntityDescription *)entity {
	if (keys.count == 0) return;
	[_uniqueKeysByEntity setObject:[keys copy] forKey:entity];
}

- (BOOL)shouldDeserializeNilValuesForEntity:(NSEntityDescription *)entity {
	return [[_shouldDeserializeNilValuesByEntity objectForKey:entity] boolValue];
}

- (void)setShouldDeserializeNilValues:(BOOL)shouldDeserializeNilValues forEntity:(NSEntityDescription *)entity {
	[_shouldDeserializeNilValuesByEntity setObject:@(shouldDeserializeNilValues) forKey:entity];
}

- (NSString *)serializationNameForProperty:(NSPropertyDescription *)property {
	NSString *serializationName = [_serializationNamesByProperty objectForKey:property];
	if (serializationName.length == 0) serializationName = property.name;
	return serializationName;
}

- (void)setSerializationName:(NSString *)serializationName forProperty:(NSPropertyDescription *)property {
	if (serializationName.length == 0) return;
	[_serializationNamesByProperty setObject:[serializationName copy] forKey:property];
}

- (NSArray *)transformerNamesForAttibute:(NSAttributeDescription *)attribute {
	return [_transformerNamesByAttribute objectForKey:attribute];
}

- (void)setTransformerNames:(NSArray *)transformerNames forAttibute:(NSAttributeDescription *)attribute {
	if (transformerNames.count == 0) return;
	[_transformerNamesByAttribute setObject:[transformerNames copy] forKey:attribute];
}

- (BOOL)serializationShouldBeUnionForRelationship:(NSRelationshipDescription *)relationship {
	return [[_serializationShouldBeUnionByRelationship objectForKey:relationship] boolValue];
}

- (void)setSerializationShouldBeUnion:(BOOL)serializationShouldBeUnion forRelationship:(NSRelationshipDescription *)relationship {
	[_serializationShouldBeUnionByRelationship setObject:@(serializationShouldBeUnion) forKey:relationship];
}

@end
