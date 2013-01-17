//
//  _DCTManagedObjectDeserializer.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectDeserializer.h"
#import "DCTManagedObjectSerializationProperties.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"
#import "NSManagedObject+DCTManagedObjectSerialization.h"

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

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((nonnull(1)));
{
	self = [self init];
	if (!self) return nil;

	_managedObjectContext = managedObjectContext;
	
#if !__has_feature(objc_arc)
	[_managedObjectContext retain];
#endif
	
	return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	
	[_dictionary release];
	[_entity release];
	[_managedObjectContext release];
	[_serializationNameToPropertyNameMapping release];
    [_errors release];
	
	[super dealloc];
}
#endif

- (id)deserializeObjectWithEntity:(NSEntityDescription *)entity fromDictionary:(NSDictionary *)dictionary __attribute__((nonnull(1,2)));
{
    NSDictionary *oldDictionary = _dictionary;
    _dictionary = dictionary;
    
    NSEntityDescription *oldEntity = _entity;
    _entity = entity;
    
	NSManagedObject *managedObject = [self _existingObject];
    
	if (!managedObject) {
		managedObject = [[NSManagedObject alloc] initWithEntity:_entity insertIntoManagedObjectContext:_managedObjectContext];
		
#if !__has_feature(objc_arc)
		[managedObject autorelease];
#endif
	}
	
	[managedObject dct_deserialize:self];
    
    // Restore the old entity & dictionary, which is crucial when this method is called reentrantly
    _dictionary = oldDictionary;
    _entity = oldEntity;
    
	return managedObject;
}

- (NSManagedObject *)_existingObject {
	NSPredicate *predicate = [self _uniqueKeysPredicate];
	if (!predicate) return nil;
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:_entity.name];
	fetchRequest.predicate = predicate;
	NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	return [result lastObject];
}

- (NSPredicate *)_uniqueKeysPredicate {
	NSArray *uniqueKeys = _entity.dct_serializationUniqueKeys;
	if (uniqueKeys.count == 0) return nil;
	NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:uniqueKeys.count];
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

#pragma mark Properties

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark Deserializing Individual Keys

- (id)deserializeObjectOfClass:(Class)class forKey:(NSString *)key __attribute__((nonnull(1,2)));
{
    id result = [_dictionary valueForKeyPath:key];
    
    if (result && ![result isKindOfClass:class])
    {
        [self recordError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSManagedObjectValidationError userInfo:@{
                       NSValidationObjectErrorKey : _dictionary,
                          NSValidationKeyErrorKey : key,
                        NSValidationValueErrorKey : result,
                           }]];
        
        result = nil;
    }
    
    return result;
}

- (id)deserializeProperty:(NSPropertyDescription *)property;
{
    Class class = [property deserializationClass];
    return (class ? [self deserializeObjectOfClass:class forKey:property.dct_serializationName] : nil);
}

- (NSString *)deserializeStringForKey:(NSString *)key __attribute__((nonnull(1)));
{
    return [self deserializeObjectOfClass:[NSString class] forKey:key];
}

- (NSURL *)deserializeURLForKey:(NSString *)key __attribute__((nonnull(1)));
{
    NSString *urlString = [self deserializeStringForKey:key];
    return (urlString ? [NSURL URLWithString:urlString] : nil);
}

- (BOOL)containsValueForKey:(NSString *)key __attribute__((nonnull(1)));
{
    return [_dictionary valueForKeyPath:key] != nil;
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
		_serializationNameToPropertyNameMapping = serializationNameToPropertyNameMapping;
	}

	return _serializationNameToPropertyNameMapping;
}

#pragma mark Error Reporting

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

- (void)recordError:(NSError *)error __attribute__((nonnull(1)));
{
    if (!_errors) _errors = [[NSMutableArray alloc] initWithCapacity:1];
    [_errors addObject:error];
}

- (NSArray *)errors;
{
    return [[_errors mutableCopy] autorelease];
}

#pragma mark Debugging

+ (NSString *)serializationDescriptionForEntitiesInManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    
	NSMutableDictionary *entityDictionary = [NSMutableDictionary dictionary];
    
	[[managedObjectModel entities] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger i, BOOL *stop) {
        
		NSMutableArray *propertyArray = [NSMutableArray array];
        
		[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {
            
			NSMutableString *string = [NSMutableString string];
			[string appendFormat:@"%@", property.name];
            
			NSMutableString *serializationPropertyString = [NSMutableString string];
			[serializationPropertyString appendString:@"("];
            
			NSString *serializationName = [property.userInfo objectForKey:@"serializationName"];
			if (serializationName) [serializationPropertyString appendFormat:@"serializationName = %@", serializationName];
            
			if ([property isKindOfClass:[NSRelationshipDescription class]]) {
				NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
				if (relationship.isToMany)
					[serializationPropertyString appendFormat:@"; serializationShouldBeUnion = %@", @(relationship.dct_serializationShouldBeUnion)];
			}
            
			if ([property isKindOfClass:[NSAttributeDescription class]]) {
				NSAttributeDescription *attribute = (NSAttributeDescription *)property;
				NSArray *serializationTransformerNames = attribute.dct_serializationTransformerNames;
				if (serializationTransformerNames)
					[serializationPropertyString appendFormat:@"; serializationTransformerNames = %@", [serializationTransformerNames componentsJoinedByString:@","]];
			}
			[serializationPropertyString appendString:@")"];
            
			if (serializationPropertyString.length > 2) [string appendFormat:@" %@", serializationPropertyString];
            
			[propertyArray addObject:string];
		}];
        
        
		NSArray *serializationUniqueKeys = entity.dct_serializationUniqueKeys;
		NSString *entityName = [NSString stringWithFormat:@"%@ (serializationUniqueKeys = %@)", entity.name, serializationUniqueKeys ? [serializationUniqueKeys componentsJoinedByString:@","] : @"none"];
		[entityDictionary setObject:propertyArray forKey:entityName];
	}];
	return [entityDictionary description];
}

@end
