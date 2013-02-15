//
//  _DCTManagedObjectDeserializer.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectDeserializer.h"
#import "_DCTManagedObjectSerializationProperties.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"
#import "NSManagedObject+DCTManagedObjectSerialization.h"


@interface DCTManagedObjectDeserializer () <DCTManagedObjectDeserializing>
@end


@implementation DCTManagedObjectDeserializer

#pragma mark Deserializing a Whole Dictionary

+ (id)deserializeObjectWithEntityName:(NSString *)entityName
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       fromDictionary:(NSDictionary *)dictionary;
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];

	DCTManagedObjectDeserializer *deserializer = [[self alloc] initWithManagedObjectContext:managedObjectContext];
	NSManagedObject *result = [deserializer deserializeObjectWithEntity:entity fromDictionary:dictionary];
	
#if !__has_feature(objc_arc)
	[deserializer release];
#endif
	
    return result;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSAssert(managedObjectContext != nil, @"managedObjectContext should not be nil");
	self = [self init];
	if (!self) return nil;

	_managedObjectContext = managedObjectContext;

#if !__has_feature(objc_arc)
	[_managedObjectContext retain];
#endif
	
	_uniqueKeysByEntity = [NSMutableDictionary new];
	_shouldDeserializeNilValuesByEntity = [NSMutableDictionary new];
	_serializationNamesByProperty = [NSMutableDictionary new];
	_transformerNamesByAttribute = [NSMutableDictionary new];
	_serializationShouldBeUnionByRelationship = [NSMutableDictionary new];

	NSArray *entities = [_managedObjectContext.persistentStoreCoordinator.managedObjectModel entities];
	[entities enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger i, BOOL *stop) {

		[self setUniqueKeys:entity.dct_serializationUniqueKeys forEntity:entity];

		NSNumber *shouldDeserializeNilValues = entity.dct_shouldDeserializeNilValues;
		if (shouldDeserializeNilValues) [self setShouldDeserializeNilValues:shouldDeserializeNilValues forEntity:entity];

		[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {

			[self setSerializationName:property.dct_serializationName forProperty:property];

			if ([property isKindOfClass:[NSAttributeDescription class]]) {
				NSAttributeDescription *attribute = (NSAttributeDescription *)property;
				[self setTransformerNames:attribute.dct_serializationTransformerNames forAttibute:attribute];
			}

			if ([property isKindOfClass:[NSRelationshipDescription class]]) {
				NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
				NSNumber *serializationShouldBeUnion = relationship.dct_serializationShouldBeUnion;
				if (serializationShouldBeUnion) [self setSerializationShouldBeUnion:serializationShouldBeUnion forRelationship:relationship];
			}
		}];
	}];
	
	return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	[_dictionary release];
	[_managedObjectContext release];
    [_errors release];
	[_uniqueKeysByEntity release];
	[_shouldDeserializeNilValuesByEntity release];
	[_serializationNamesByProperty release];
	[_transformerNamesByAttribute release];
	[_serializationShouldBeUnionByRelationship release];
	[super dealloc];
}
#endif

- (id)deserializeObjectWithEntity:(NSEntityDescription *)entity fromDictionary:(NSDictionary *)dictionary {
	NSAssert(entity, @"entity should not be nil");
	NSAssert(dictionary, @"dictionary should not be nil");

    return [self deserializeObjectUsingBlock:^id{
        
        NSDictionary *oldDictionary = _dictionary;
        _dictionary = dictionary;
        
        NSManagedObject *managedObject = [self existingObjectWithDictionary:dictionary entity:entity managedObjectContext:_managedObjectContext];
        
        if (!managedObject) {
            managedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
            
#if !__has_feature(objc_arc)
            [managedObject autorelease];
#endif
        }
        
        [managedObject dct_deserialize:self];
        
        // Restore the old dictionary, which is crucial when this method is called reentrantly
        _dictionary = oldDictionary;

		if ([self.delegate respondsToSelector:@selector(deserializer:didDeserializeObject:)])
			[self.delegate deserializer:self didDeserializeObject:managedObject];

        return managedObject;
    }];
}

- (id)deserializeObjectUsingBlock:(id (^)(void))block {
    // Outermost call to this requires some setup
    if (!_dictionary)
    {
        // Previous deserializations must be cleared away
#if !__has_feature(objc_arc)
        [_errors release];
#endif
		_errors = nil;
        
        // For the outermost call, install a undo group to perform error recovery with
        // TODO: On 10.7/iOS5+ could instead do the changes into a child MOC
        NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
        if (!undoManager)
        {
            // Install an undo manager temporarily
            undoManager = [[NSUndoManager alloc] init];
            [[self managedObjectContext] setUndoManager:undoManager];
            
            // Try again now we have an undo manager
            id result = [self deserializeObjectUsingBlock:block];
            
            // Clear up
            [[self managedObjectContext] setUndoManager:nil];

#if !__has_feature(objc_arc)
            [undoManager release];
#endif
			
            return  result;
        }
        
        [undoManager beginUndoGrouping];
        
        id result = block();
        
        [undoManager endUndoGrouping];
        
        // If there were one or more errors, pretend those changes never happened
        if ([self errors])
        {
            [undoManager undoNestedGroup];
            result = nil;
        }
        
        return result;
    }
    else
    {
        return block();
    }
}

#pragma mark - Properties

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Deserializing Individual Keys

- (id)deserializeObjectOfClass:(Class)class forKey:(NSString *)key {
    id result = [_dictionary valueForKeyPath:key];
    
    if (result && ![result isKindOfClass:class]) {
        [self recordError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSManagedObjectValidationError userInfo:@{
                       NSValidationObjectErrorKey : _dictionary,
                          NSValidationKeyErrorKey : key,
                        NSValidationValueErrorKey : result,
                           }]];
        
        result = nil;
    }
    
    return result;
}

- (id)deserializeProperty:(NSPropertyDescription *)property {
    Class class = [property dct_deserializationClassWithDeserializer:self];
	if (!class) return nil;
	NSString *serializationName = [self serializationNameForProperty:property];
    return [self deserializeObjectOfClass:class forKey:serializationName];
}

- (NSString *)deserializeStringForKey:(NSString *)key {
    return [self deserializeObjectOfClass:[NSString class] forKey:key];
}

- (NSURL *)deserializeURLForKey:(NSString *)key {
    NSString *urlString = [self deserializeStringForKey:key];
    return (urlString ? [NSURL URLWithString:urlString] : nil);
}

- (BOOL)containsValueForKey:(NSString *)key {
    return [_dictionary valueForKeyPath:key] != nil;
}

- (id)serializedValueForKey:(NSString *)key {
	return [_dictionary valueForKeyPath:key];
}

#pragma mark - Error Reporting

- (void)recordError:(NSError *)error forKey:(NSString *)key;
{
    // Construct an error around the serialized state
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
    [userInfo setValue:[error localizedDescription] forKey:NSLocalizedDescriptionKey];
    [userInfo setValue:[error localizedFailureReason] forKey:NSLocalizedFailureReasonErrorKey];
    [userInfo setValue:[error localizedRecoverySuggestion] forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    [userInfo setObject:_dictionary forKey:NSValidationObjectErrorKey];
    [userInfo setObject:key forKey:NSValidationKeyErrorKey];
    [userInfo setValue:[_dictionary valueForKeyPath:key] forKey:NSValidationValueErrorKey];
    [userInfo setValue:error forKey:NSUnderlyingErrorKey];
    
    if (error)
    {
        error = [NSError errorWithDomain:[error domain] code:[error code] userInfo:userInfo];
    }
    else
    {
        // Fallback to generic error
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSManagedObjectValidationError userInfo:userInfo];
    }
    
    [self recordError:error];
}

- (void)recordError:(NSError *)error {
    if (!_errors) _errors = [[NSMutableArray alloc] initWithCapacity:1];
    [_errors addObject:error];
}

- (NSArray *)errors;
{
#if __has_feature(objc_arc)
	return [_errors copy];
#else
	return [[_errors copy] autorelease];
#endif
}

#pragma mark - Debugging

- (NSString *)serializationPropertiesDescription {

	NSDictionary *dictionary = @{
		@"uniqueKeys": _uniqueKeysByEntity,
		@"serializationNames" : _serializationNamesByProperty,
		@"shouldDeserializeNilValues" : _shouldDeserializeNilValuesByEntity,
		@"transformerNames" : _transformerNamesByAttribute,
		@"serializationShouldBeUnion" : _serializationShouldBeUnionByRelationship
	};

	return [dictionary description];
}

#pragma mark - Serialization Properties

- (NSString *)keyForProperty:(NSPropertyDescription *)property {
	return [NSString stringWithFormat:@"%@.%@", property.entity.name, property.name];
}

- (NSString *)keyForEntity:(NSEntityDescription *)entity {
	return entity.name;
}

- (NSArray *)uniqueKeysForEntity:(NSEntityDescription *)entity {
	NSString *key = [self keyForEntity:entity];
	return [_uniqueKeysByEntity objectForKey:key];
}

- (void)setUniqueKeys:(NSArray *)keys forEntity:(NSEntityDescription *)entity {
	NSString *key = [self keyForEntity:entity];
	if (keys.count == 0)
		[_uniqueKeysByEntity removeObjectForKey:key];
	else {
		NSArray *keysCopy = [keys copy];
		[_uniqueKeysByEntity setObject:keysCopy forKey:key];
#if !__has_feature(objc_arc)
		[keysCopy release];
#endif
	}
}

- (BOOL)shouldDeserializeNilValuesForEntity:(NSEntityDescription *)entity {
	NSString *key = [self keyForEntity:entity];
	NSNumber *shouldDeserializeNilValues = [_shouldDeserializeNilValuesByEntity objectForKey:key];
	if (!shouldDeserializeNilValues) return YES;
	return [shouldDeserializeNilValues boolValue];
}

- (void)setShouldDeserializeNilValues:(BOOL)shouldDeserializeNilValues forEntity:(NSEntityDescription *)entity {
	NSString *key = [self keyForEntity:entity];
	[_shouldDeserializeNilValuesByEntity setObject:@(shouldDeserializeNilValues) forKey:key];
}

- (NSString *)serializationNameForProperty:(NSPropertyDescription *)property {
	NSString *key = [self keyForProperty:property];
	NSString *serializationName = [_serializationNamesByProperty objectForKey:key];
	if (serializationName.length == 0) serializationName = property.name;
	return serializationName;
}

- (void)setSerializationName:(NSString *)serializationName forProperty:(NSPropertyDescription *)property {
	NSString *key = [self keyForProperty:property];
	if (serializationName.length == 0)
		[_serializationNamesByProperty removeObjectForKey:key];
	else {
		NSArray *serializationNameCopy = [serializationName copy];
		[_serializationNamesByProperty setObject:serializationNameCopy forKey:key];
#if !__has_feature(objc_arc)
		[serializationNameCopy release];
#endif
	}
}

- (NSArray *)transformerNamesForAttribute:(NSAttributeDescription *)attribute {
	NSString *key = [self keyForProperty:attribute];
	return [_transformerNamesByAttribute objectForKey:key];
}

- (void)setTransformerNames:(NSArray *)transformerNames forAttibute:(NSAttributeDescription *)attribute {
	NSString *key = [self keyForProperty:attribute];
	if (transformerNames.count == 0)
		[_transformerNamesByAttribute removeObjectForKey:key];
	else {
		NSArray *transformerNamesCopy = [transformerNames copy];
		[_transformerNamesByAttribute setObject:transformerNamesCopy forKey:key];
#if !__has_feature(objc_arc)
		[transformerNamesCopy release];
#endif
	}
}

- (BOOL)serializationShouldBeUnionForRelationship:(NSRelationshipDescription *)relationship {
	NSString *key = [self keyForProperty:relationship];
	NSNumber *serializationShouldBeUnion = [_serializationShouldBeUnionByRelationship objectForKey:key];
	if (!serializationShouldBeUnion) return NO;
	return [serializationShouldBeUnion boolValue];
}

- (void)setSerializationShouldBeUnion:(BOOL)serializationShouldBeUnion forRelationship:(NSRelationshipDescription *)relationship {
	NSString *key = [self keyForProperty:relationship];
	[_serializationShouldBeUnionByRelationship setObject:@(serializationShouldBeUnion) forKey:key];
}

#pragma mark - Internal

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
    
#if !__has_feature(objc_arc)
    [fetchRequest release];
#endif
    
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
		id serializationValue = [dictionary valueForKeyPath:serializationName];
		id value = [property dct_valueForSerializedValue:serializationValue withDeserializer:self];
		if (!value) return;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, value];
		[predicates addObject:predicate];
	}];
	if (predicates.count == 0) return nil;
	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

@end
