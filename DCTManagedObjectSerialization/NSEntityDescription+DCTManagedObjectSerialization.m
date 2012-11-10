//
//  NSEntityDescription+DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSEntityDescription+DCTManagedObjectSerialization.h"

NSString *const DCTSerializationUniqueKeys = @"serializationUniqueKeys";

@implementation NSEntityDescription (DCTManagedObjectSerialization)

- (NSArray *)dct_serializationUniqueKeys {
	NSString *uniqueKeys = [self.userInfo objectForKey:DCTSerializationUniqueKeys];
	return [uniqueKeys componentsSeparatedByString:@","];
}

- (void)setDct_serializationUniqueKeys:(NSArray *)dct_serializationUniqueKeys {
	NSString *uniqueKeys = [dct_serializationUniqueKeys componentsJoinedByString:@","];
	[self dct_setUserInfoValue:uniqueKeys forKey:DCTSerializationUniqueKeys];
}

- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key {
	NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
	[userInfo setObject:value forKey:key];
	self.userInfo = [userInfo copy];
}

@end
