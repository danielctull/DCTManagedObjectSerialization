//
//  NSPropertyDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"

@implementation NSPropertyDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer;
{
	return nil;
}

- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key {
	NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
	[userInfo setObject:value forKey:key];
	self.userInfo = [userInfo copy];
}

@end
