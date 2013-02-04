//
//  NSAttributeDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSAttributeDescription+_DCTManagedObjectSerialization.h"
#import "DCTManagedObjectSerialization.h"

@implementation NSAttributeDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	__block id transformedValue = value;

	NSArray *transformerNames = [deserializer transformerNamesForAttibute:self];
	[transformerNames enumerateObjectsUsingBlock:^(NSString *transformerName, NSUInteger idx, BOOL *stop) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:transformerName];
		transformedValue = [transformer transformedValue:transformedValue];
	}];

	if (self.attributeType == NSTransformableAttributeType)
		return transformedValue;

	Class attributeClass = NSClassFromString(self.attributeValueClassName);

	if ([transformedValue isKindOfClass:attributeClass])
		return transformedValue;

	if ([value isKindOfClass:attributeClass])
			return value;

	return nil;
}

@end
