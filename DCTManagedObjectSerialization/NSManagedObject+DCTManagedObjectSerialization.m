//
//  NSManagedObject+DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSManagedObject+DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"

@implementation NSManagedObject (DCTManagedObjectSerialization)

- (void)dct_deserializeProperty:(NSPropertyDescription *)property withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer __attribute__((nonnull(1,2))) {
    id value = [deserializer deserializeProperty:property];
    
    // Nil can arise because:
    //  * the serialization is corrupt (i.e. contains the wrong class)
    //  * there's no such key in the serialization, which can be because:
    //      * it's a property that was nil in the source
    //      * the serialization only covers a subset of attributes (common when deserializing JSON from a server). Entity's dct_shouldDeserializeNilValues property covers this
    //      * it's a relationship not intended to be serialized/deserialized (e.g. relationship to parent object)
    //
    // Only the first one merits reporting an error (which -deserializeProperty:) will have done internally. For the others, they're not errors; just continue on
    if (!value)
    {
		NSString *serializationName = [deserializer serializationNameForProperty:property];
		if ([deserializer containsValueForKey:serializationName]) return;
		if (![deserializer shouldDeserializeNilValuesForEntity:self.entity]) return;
		if ([property isKindOfClass:[NSRelationshipDescription class]]) return;
    }
    
    // Apply any transform the property uses
    id transformedValue = [property dct_valueForSerializedValue:value withDeserializer:deserializer];
    
    // Check the value will be OK
    NSString *key = [property name];
    
    NSError *error;
    if (![self validateValue:&transformedValue forKey:key error:&error])
    {
		NSString *serializationName = [deserializer serializationNameForProperty:property];
        [deserializer recordError:error forKey:serializationName];
        return;
    }
    
    // For attributes, know we can set primitive value so as to avoid any possible side effects from custom setter methods. Other properties fall back to generic KVC
    if ([property isKindOfClass:[NSAttributeDescription class]])
    {
        [self willChangeValueForKey:key];
        [self setPrimitiveValue:transformedValue forKey:key];
        [self didChangeValueForKey:key];
		return;
    }

	if ([property isKindOfClass:[NSRelationshipDescription class]]) {
		NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
		if (relationship.isToMany && [deserializer serializationShouldBeUnionForRelationship:relationship]) {
			NSMutableSet *set = [self mutableSetValueForKey:key];
			[set unionSet:transformedValue];
			return;
		}
	}

	[self setValue:transformedValue forKey:key];
}

- (void)dct_deserialize:(id <DCTManagedObjectDeserializing>)deserializier {
    NSEntityDescription *entity = self.entity;
    
	[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {
        
		// Skip transient properties
		if ([property isTransient]) return;
		
        [self dct_deserializeProperty:property withDeserializer:deserializier];
	}];
}

@end
