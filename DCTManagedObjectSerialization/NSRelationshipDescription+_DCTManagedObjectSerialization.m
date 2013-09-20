//
//  NSRelationshipDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSRelationshipDescription+_DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"
#import "DCTManagedObjectDeserializer.h"

@implementation NSRelationshipDescription (_DCTManagedObjectSerialization)

- (Class)dct_deserializationClassWithDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	// If there's any transformers, allow anything (like attributes).
	NSArray *transformerNames = [deserializer transformerNamesForProperty:self];
	if (transformerNames.count > 0) return [NSObject class];

	if (self.isToMany) return [NSArray class];

	return [NSDictionary class];
}

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	id transformedValue = [super dct_valueForSerializedValue:value withDeserializer:deserializer];

	if (!self.isToMany) {
		
		if ([transformedValue isKindOfClass:[NSDictionary class]])
			return [self dct_valueForSerializedDictionary:transformedValue deserializer:deserializer];

		return nil;
	}

	if ([self respondsToSelector:@selector(isOrdered)] && self.isOrdered) {
		NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:[transformedValue count]];
		[self dct_populateCollection:result fromSerializedObjects:transformedValue deserializer:deserializer];
		return result;
	} else {
		NSMutableSet *result = [NSMutableSet setWithCapacity:[transformedValue count]];
		[self dct_populateCollection:result fromSerializedObjects:transformedValue deserializer:deserializer];
		return result;
	}
}

- (void)dct_populateCollection:(id)collection fromSerializedObjects:(NSArray *)array deserializer:(id <DCTManagedObjectDeserializing>)deserializer;
{
	[array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger i, BOOL *stop) {
		
        if (![dictionary isKindOfClass:[NSDictionary class]])
        {
            // Likely corrupt serialization
            [deserializer recordError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                          code:NSManagedObjectValidationError
                                                      userInfo:@{ NSValidationValueErrorKey : dictionary }]];
            return;
        }
        
        id object = [self dct_valueForSerializedDictionary:dictionary deserializer:deserializer];
		[collection addObject:object];
	}];
}

- (id)dct_valueForSerializedDictionary:(NSDictionary *)dictionary deserializer:(id <DCTManagedObjectDeserializing>)deserializer;
{
	NSEntityDescription *entity = nil;
    if ([dictionary objectForKey:@"entity"])
    {
        NSString *name = [dictionary objectForKey:@"entity"];
        if ([name isKindOfClass:[NSString class]])
        {
            entity = [NSEntityDescription entityForName:name
                                 inManagedObjectContext:[(id)deserializer managedObjectContext]];   // HACK
        }
    }
    
    if (!entity) entity = self.destinationEntity;
    
	NSManagedObject *result = [deserializer deserializeObjectWithEntity:entity fromDictionary:dictionary];
	
	return result;
}

@end
