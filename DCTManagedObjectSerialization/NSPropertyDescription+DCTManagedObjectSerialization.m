//
//  NSPropertyDescription+DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSPropertyDescription+DCTManagedObjectSerialization.h"

NSString *const DCTSerializationName = @"serializationName";
NSString *const DCTSerializationTransformerClass = @"serializationTransformerClass";

@implementation NSPropertyDescription (DCTManagedObjectSerialization)

- (NSString *)dct_serializationName {
	return [self.userInfo objectForKey:DCTSerializationName];
}

- (void)setDct_serializationName:(NSString *)dct_serializationName {
	[self dct_setUserInfoValue:[dct_serializationName copy] forKey:DCTSerializationName];
}

- (Class)dct_serializationTransformerClass {
	NSString *className = [self.userInfo objectForKey:DCTSerializationTransformerClass];
	return NSClassFromString(className);
}

- (void)setDct_serializationTransformerClass:(Class)dct_serializationTransformerClass {
	[self dct_setUserInfoValue:NSStringFromClass(dct_serializationTransformerClass) forKey:DCTSerializationTransformerClass];
}

- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key {
	NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
	[userInfo setObject:value forKey:key];
	self.userInfo = [userInfo copy];
}

@end
