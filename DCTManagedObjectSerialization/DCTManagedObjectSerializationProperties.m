//
//  DCTManagedObjectSerializationProperties.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 12.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectSerializationProperties.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"

NSString *const DCTSerializationUniqueKeys = @"serializationUniqueKeys";
NSString *const DCTSerializationShouldDeserializeNilValues = @"shouldDeserializeNilValues";
NSString *const DCTSerializationName = @"serializationName";
NSString *const DCTSerializationTransformerNames = @"serializationTransformerNames";
NSString *const DCTSerializationShouldBeUnion = @"serializationShouldBeUnion";




@implementation NSEntityDescription (DCTManagedObjectSerializationProperties)

- (NSArray *)dct_serializationUniqueKeys {
	NSString *uniqueKeys = [self.userInfo objectForKey:DCTSerializationUniqueKeys];
	return [uniqueKeys componentsSeparatedByString:@","];
}

- (void)setDct_serializationUniqueKeys:(NSArray *)dct_serializationUniqueKeys {
	NSString *uniqueKeys = [dct_serializationUniqueKeys componentsJoinedByString:@","];
	[self dct_setUserInfoValue:uniqueKeys forKey:DCTSerializationUniqueKeys];
}

- (BOOL)dct_shouldDeserializeNilValues {
	NSString *shouldDeserializeNilValues = [self.userInfo objectForKey:DCTSerializationShouldDeserializeNilValues];
	if (shouldDeserializeNilValues.length == 0) return YES;
	return [shouldDeserializeNilValues boolValue];
}

- (void)setDct_shouldDeserializeNilValues:(BOOL)dct_shouldDeserializeNilValues {
	NSString *shouldDeserializeNilValues = [@(dct_shouldDeserializeNilValues) description];
	[self dct_setUserInfoValue:shouldDeserializeNilValues forKey:DCTSerializationShouldDeserializeNilValues];
}

- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key {
	NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
	[userInfo setObject:value forKey:key];
	self.userInfo = userInfo;

#if !__has_feature(objc_arc)
	[userInfo release];
#endif
}

@end





@implementation NSPropertyDescription (DCTManagedObjectSerializationProperties)

- (NSString *)dct_serializationName {
	NSString *serializationName = [self.userInfo objectForKey:DCTSerializationName];
	if (serializationName.length > 0) return serializationName;
	return self.name;
}

- (void)setDct_serializationName:(NSString *)dct_serializationName {
	dct_serializationName = [dct_serializationName copy];
	[self dct_setUserInfoValue:dct_serializationName forKey:DCTSerializationName];
	
#if !__has_feature(objc_arc)
	[dct_serializationName release];
#endif
}

@end





@implementation NSAttributeDescription (DCTManagedObjectSerializationProperties)

- (NSArray *)dct_serializationTransformerNames {
	NSString *serializationTransformerNames = [self.userInfo objectForKey:DCTSerializationTransformerNames];
	return [serializationTransformerNames componentsSeparatedByString:@","];
}

- (void)setDct_serializationTransformerNames:(NSArray *)dct_serializationTransformerNames {
	NSString *serializationTransformerNames = [dct_serializationTransformerNames componentsJoinedByString:@","];
	[self dct_setUserInfoValue:serializationTransformerNames forKey:DCTSerializationTransformerNames];
}

@end





@implementation NSRelationshipDescription (DCTManagedObjectSerializationProperties)

- (BOOL)dct_serializationShouldBeUnion {
	NSString *serializationShouldBeUnion = [self.userInfo objectForKey:DCTSerializationName];
	return [serializationShouldBeUnion boolValue];
}

- (void)setDct_serializationShouldBeUnion:(BOOL)dct_serializationShouldBeUnion {
	NSString *serializationShouldBeUnion = [@(dct_serializationShouldBeUnion) description];
	[self dct_setUserInfoValue:serializationShouldBeUnion forKey:DCTSerializationShouldBeUnion];
}

@end
