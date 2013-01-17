//
//  NSManagedObject+DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSManagedObject+DCTManagedObjectSerialization.h"
#import "DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"

@implementation NSManagedObject (DCTManagedObjectSerialization)

- (void)dct_deserializeProperty:(NSPropertyDescription *)property withDeserializer:(DCTManagedObjectDeserializer *)deserializer;
{
    id value = [deserializer deserializeProperty:property];
    
    // Bail out if nil value is unacceptable, or due to an error
    if (!value)
    {
        if ([deserializer containsValueForKey:property.dct_serializationName] || !self.entity.dct_shouldDeserializeNilValues) return;
    }
    
    // Apply any transform the property uses
    id transformedValue = [property dct_valueForSerializedValue:value inManagedObjectContext:self.managedObjectContext];
    
    // Check the value will be OK
    NSString *key = [property name];
    
    NSError *error;
    if (![self validateValue:&transformedValue forKey:key error:&error])
    {
        [deserializer recordError:error forKey:property.dct_serializationName];
        return;
    }
    
    // For attributes, know we can set primitive value so as to avoid any possible side effects from custom setter methods. Other properties fall back to generic KVC
    if ([property isKindOfClass:[NSAttributeDescription class]])
    {
        [self willChangeValueForKey:key];
        [self setPrimitiveValue:transformedValue forKey:key];
        [self didChangeValueForKey:key];
    }
    else
    {
        [self setValue:transformedValue forKey:key];
    }
}

- (void)dct_deserialize:(DCTManagedObjectDeserializer *)deserializier;
{
    NSEntityDescription *entity = self.entity;
    
	[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {
        
		// Skip transient properties
		if ([property isTransient]) return;
		
        [self dct_deserializeProperty:property withDeserializer:deserializier];
	}];
}

@end
