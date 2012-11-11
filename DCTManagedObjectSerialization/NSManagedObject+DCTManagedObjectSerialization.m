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

- (void)dct_setSerializedValue:(id)value forKey:(NSString *)key {
	NSPropertyDescription *property = [self.entity.propertiesByName objectForKey:key];
	id transformedValue = [property dct_valueForSerializedValue:value inManagedObjectContext:self.managedObjectContext];
	if (transformedValue) [self setValue:transformedValue forKey:key];
}

@end
