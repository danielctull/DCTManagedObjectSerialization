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

- (void)dct_setSerializedValue:(id)value forKey:(NSString *)key {
	NSPropertyDescription *property = [self.entity.propertiesByName objectForKey:key];
	id transformedValue = [property dct_valueForSerializedValue:value inManagedObjectContext:self.managedObjectContext];
    
    // For attributes, know we can set primitive value so as to avoid any possible side effects from custom setter methods. Other properties fall back to generic KVC
    if ([property isKindOfClass:[NSAttributeDescription class]])
    {
        // Check the value will be OK
        if (![self validateValue:&transformedValue forKey:key error:NULL]) return;
        
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
		
        Class class = property.deserializationClass;
        if (class)
        {
            NSString *serializationName = property.dct_serializationName;
            id serializedValue = [deserializier deserializeObjectOfClass:class forKey:serializationName];
            
            if (serializedValue || entity.dct_shouldDeserializeNilValues)
                [self dct_setSerializedValue:serializedValue forKey:property.name];
        }
	}];
}

@end
