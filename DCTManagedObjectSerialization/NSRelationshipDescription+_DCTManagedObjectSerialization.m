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

	if ([self respondsToSelector:@selector(isOrdered)] && self.isOrdered) {
		
		NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:[value count]];
		[self dct_populateCollection:result fromSerializedObjects:value managedObjectContext:managedObjectContext];
		return result;
	}
	else {
		NSMutableSet *result = [NSMutableSet setWithCapacity:[value count]];
		[self dct_populateCollection:result fromSerializedObjects:value managedObjectContext:managedObjectContext];
		return result;
	}
}

- (void)dct_populateCollection:(id)collection fromSerializedObjects:(NSArray *)array managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	[array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger i, BOOL *stop) {
		id object = [self dct_valueForSerializedDictionary:dictionary managedObjectContext:managedObjectContext];
		[collection addObject:object];
	}];
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
	NSManagedObject *result = [deserializer deserializedObject];
	
#if !__has_feature(objc_arc)
	[deserializer release];
#endif
	
	return result;
}

@end
