//
//  NSAttributeDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSAttributeDescription+_DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+_DCTManagedObjectSerialization.h"
#import "DCTManagedObjectSerialization.h"

@implementation NSAttributeDescription (_DCTManagedObjectSerialization)

- (Class)dct_deserializationClassWithDeserializer:(id<DCTManagedObjectDeserializing>)deserializer {

	// For transformable attributes, have no good idea what the source class is.
	// Assume that the transformer will reject anything unsuitable, so allow basically anything

	BOOL classUnknown = (self.attributeType == NSTransformableAttributeType || [deserializer transformerNamesForAttribute:self].count);
	return classUnknown ? [NSObject class] : NSClassFromString([self attributeValueClassName]);
}

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	__block id transformedValue = value;

	NSArray *transformerNames = [deserializer transformerNamesForAttribute:self];
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
