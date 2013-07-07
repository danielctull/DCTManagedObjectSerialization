//
//  DCTManagedObjectSerializationProperties.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 12.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTManagedObjectSerializationProperties.h"
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

- (NSNumber *)dct_shouldDeserializeNilValues {
	NSString *shouldDeserializeNilValues = [self.userInfo objectForKey:DCTSerializationShouldDeserializeNilValues];
	if (shouldDeserializeNilValues.length == 0) return nil;
	return @([shouldDeserializeNilValues boolValue]);
}

@end





@implementation NSPropertyDescription (DCTManagedObjectSerializationProperties)

- (NSString *)dct_serializationName {
	return [self.userInfo objectForKey:DCTSerializationName];
}

- (NSArray *)dct_serializationTransformerNames {
	NSString *serializationTransformerNames = [self.userInfo objectForKey:DCTSerializationTransformerNames];
	return [serializationTransformerNames componentsSeparatedByString:@","];
}

@end





@implementation NSRelationshipDescription (DCTManagedObjectSerializationProperties)

- (NSNumber *)dct_serializationShouldBeUnion {
	NSString *serializationShouldBeUnion = [self.userInfo objectForKey:DCTSerializationName];
	if (serializationShouldBeUnion.length == 0) return nil;
	return @([serializationShouldBeUnion boolValue]);
}

@end
