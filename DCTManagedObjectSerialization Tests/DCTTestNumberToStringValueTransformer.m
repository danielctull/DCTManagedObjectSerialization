//
//  DCTTestNumberToStringValueTransformer.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 12.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTestNumberToStringValueTransformer.h"

@implementation DCTTestNumberToStringValueTransformer

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (nullable id)transformedValue:(nullable id)value {

	if (![value isKindOfClass:[NSNumber class]]) {
		return nil;
	}

	NSNumber *number = value;
	return [number description];
}

@end
