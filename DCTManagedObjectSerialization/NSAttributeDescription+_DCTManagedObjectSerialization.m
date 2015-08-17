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

	BOOL classUnknown = (self.attributeType == NSTransformableAttributeType || [deserializer transformerNamesForProperty:self].count);
	if (classUnknown) {
		return [NSObject class];
	}

	NSString *attributeValueClassName = self.attributeValueClassName;
	if (!attributeValueClassName) {
		return [NSObject class];
	}

	Class attributeClass = NSClassFromString(attributeValueClassName);
	if (!attributeClass) {
		return [NSObject class];
	}

	return attributeClass;
}

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	id transformedValue = [super dct_valueForSerializedValue:value withDeserializer:deserializer];

	if (self.attributeType == NSTransformableAttributeType) {
		return transformedValue;
	}

	NSString *attributeValueClassName = self.attributeValueClassName;
	if (!attributeValueClassName) {
		return nil;
	}

	Class attributeClass = NSClassFromString(attributeValueClassName);
	if (!attributeClass) {
		return nil;
	}

	if ([transformedValue isKindOfClass:attributeClass]) {
		return transformedValue;
	}

	if ([value isKindOfClass:attributeClass]) {
		return value;
	}

	return nil;
}

@end
