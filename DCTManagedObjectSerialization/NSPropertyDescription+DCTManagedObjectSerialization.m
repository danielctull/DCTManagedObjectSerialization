//
//  NSPropertyDescription+DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSPropertyDescription+DCTManagedObjectSerialization.h"

NSString *const DCTSerializationName = @"serializationName";
NSString *const DCTSerializationTransformerNames = @"serializationTransformerNames";

@implementation NSPropertyDescription (DCTManagedObjectSerialization)

- (NSString *)dct_serializationName {
	NSString *serializationName = [self.userInfo objectForKey:DCTSerializationName];
	if (serializationName.length > 0) return serializationName;
	return self.name;
}

- (void)setDct_serializationName:(NSString *)dct_serializationName {
	[self dct_setUserInfoValue:[dct_serializationName copy] forKey:DCTSerializationName];
}

- (NSArray *)dct_serializationTransformerNames {
	NSString *serializationTransformerNames = [self.userInfo objectForKey:DCTSerializationTransformerNames];
	return [serializationTransformerNames componentsSeparatedByString:@","];
}

- (void)setDct_serializationTransformerNames:(NSArray *)dct_serializationTransformerNames {
	NSString *serializationTransformerNames = [dct_serializationTransformerNames componentsJoinedByString:@","];
	[self dct_setUserInfoValue:serializationTransformerNames forKey:DCTSerializationTransformerNames];
}

- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key {
	NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
	[userInfo setObject:value forKey:key];
	self.userInfo = [userInfo copy];
}

@end
