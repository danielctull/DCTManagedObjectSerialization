//
//  NSPropertyDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"

@implementation NSPropertyDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	return nil;
}

@end
