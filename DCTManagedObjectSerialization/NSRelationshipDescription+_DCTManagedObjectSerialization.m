//
//  NSRelationshipDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSRelationshipDescription+_DCTManagedObjectSerialization.h"
#import "_DCTManagedObjectDeserializer.h"

@implementation NSRelationshipDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	if (!self.isToMany)
		return [self dct_valueForSerializedDictionary:value managedObjectContext:managedObjectContext];

	if ([self respondsToSelector:@selector(isOrdered)] && self.isOrdered)
		return [self dct_orderedSetForSerializedArray:value managedObjectContext:managedObjectContext];

	return [self dct_setForSerializedArray:value managedObjectContext:managedObjectContext];
}

- (NSSet *)dct_setForSerializedArray:(NSArray *)array managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSOrderedSet *orderedSet = [self dct_orderedSetForSerializedArray:array managedObjectContext:managedObjectContext];
	return [orderedSet set];
}

- (NSOrderedSet *)dct_orderedSetForSerializedArray:(NSArray *)array managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet new];

	[array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger i, BOOL *stop) {
		id object = [self dct_valueForSerializedDictionary:dictionary managedObjectContext:managedObjectContext];
		[orderedSet addObject:object];
	}];	

	return [orderedSet copy];
}

- (id)dct_valueForSerializedDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;    // likely corrupt serialization

	NSEntityDescription *entity = nil;
    if ([dictionary objectForKey:@"entity"])
    {
        NSString *name = [dictionary objectForKey:@"entity"];
        if ([name isKindOfClass:[NSString class]])
        {
            entity = [NSEntityDescription entityForName:name inManagedObjectContext:managedObjectContext];
        }
        if (!entity) return nil;    // likely corrupt serialization
    }
    else
    {
        entity = self.destinationEntity;
    }
    
	_DCTManagedObjectDeserializer *deserializer = [[_DCTManagedObjectDeserializer alloc] initWithDictionary:dictionary
																									 entity:entity
																					   managedObjectContext:managedObjectContext];
	return [deserializer deserializedObject];
}

@end
