//
//  _DCTManagedObjectSerializationSecondsSince1970ValueTransformer.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTManagedObjectSerializationSecondsSince1970ValueTransformer.h"
#import "DCTManagedObjectSerialization.h"

@implementation _DCTManagedObjectSerializationSecondsSince1970ValueTransformer {
	NSNumberFormatter *_numberFormatter;
}

+ (void)load {
	@autoreleasepool {
		id transformer = [self new];
		[self setValueTransformer:transformer forName:DCTManagedObjectSerializationSecondsSince1970ValueTransformerName];
	}
}

+ (Class)transformedValueClass {
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(NSDate *)value {
	if (![value isKindOfClass:[NSDate class]]) return nil;

    return @([value timeIntervalSince1970]);
}

- (id)reverseTransformedValue:(id)value {

	if ([value isKindOfClass:[NSString class]]) {
		if (!_numberFormatter) _numberFormatter = [NSNumberFormatter new];
		value = [_numberFormatter numberFromString:value];
	}
	
	if (![value isKindOfClass:[NSNumber class]])
		return nil;

	return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
}

@end
