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

- (id)transformedValue:(NSNumber *)value {
	return [value description];
}

@end
