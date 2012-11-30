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
	if ([property isKindOfClass:[NSAttributeDescription class]]) {

		[self willChangeValueForKey:key];
		[self setPrimitiveValue:transformedValue forKey:key];
		[self didChangeValueForKey:key];

	} else if ([property isKindOfClass:[NSRelationshipDescription class]]) {

		NSLog(@"%@ %@", key, transformedValue);

		NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
		if (relationship.dct_serializationShouldBeUnion) {

			if (relationship.isOrdered) {
				NSMutableOrderedSet *set = [self dct_orderedSetForKey:key];
				[self willChangeValueForKey:key];
				[set unionOrderedSet:transformedValue];
				[self didChangeValueForKey:key];

				NSLog(@"%@", set);

			} else {
				NSMutableSet *set = [self dct_SetForKey:key];
				[set unionSet:transformedValue];
			}

		} else {
			[self setValue:transformedValue forKey:key];
		}
	}
}

- (NSMutableOrderedSet *)dct_orderedSetForKey:(NSString *)key {
	[self willAccessValueForKey:key];
	NSMutableOrderedSet *result = [self mutableOrderedSetValueForKey:key];
	[self didAccessValueForKey:key];
	return result;
}

- (NSMutableSet *)dct_SetForKey:(NSString *)key {
	[self willAccessValueForKey:key];
	NSMutableSet *result = [self mutableSetValueForKey:key];
	[self didAccessValueForKey:key];
	return result;
}


- (void)dct_awakeFromSerializedRepresentation:(NSObject *)rep;
{
    NSEntityDescription *entity = self.entity;
    
	[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {
        
        NSString *serializationName = property.dct_serializationName;
		id serializedValue = [rep valueForKeyPath:serializationName];
        
		if (serializedValue || entity.dct_shouldDeserializeNilValues)
			[self dct_setSerializedValue:serializedValue forKey:property.name];
	}];
}

@end
