//
//  DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectSerialization.h"
#import "_DCTManagedObjectDeserializer.h"

@implementation DCTManagedObjectSerialization

+ (id)objectFromDictionary:(NSDictionary *)dictionary
				rootEntity:(NSEntityDescription *)entity
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	_DCTManagedObjectDeserializer *deserializer = [[_DCTManagedObjectDeserializer alloc] initWithDictionary:dictionary
																									 entity:entity
																					   managedObjectContext:managedObjectContext];

	return [deserializer deserializedObject];
}

@end
