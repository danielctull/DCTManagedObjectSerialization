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

- (id)dct_valueForSerializedValue:(id)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	return nil;

}

- (NSArray *)dct_arrayForSerializedDictionary:(NSArray *)array managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	return nil;
}

- (id)dct_valueForSerializedDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;

	NSEntityDescription *entity = self.entity;
	_DCTManagedObjectDeserializer *deserializer = [[_DCTManagedObjectDeserializer alloc] initWithDictionary:dictionary
																									 entity:entity
																					   managedObjectContext:managedObjectContext];
	return [deserializer deserializedObject];
}

@end
