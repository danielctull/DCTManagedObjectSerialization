//
//  NSAttributeDescription+_DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSAttributeDescription+_DCTManagedObjectSerialization.h"
#import "NSPropertyDescription+DCTManagedObjectSerialization.h"

@implementation NSAttributeDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	return [self dct_valueForSerializedValue:value];
}

- (id)dct_valueForSerializedValue:(id)value {

	NSString *transformerName = self.dct_serializationTransformerName;
	if (transformerName) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:transformerName];
		if (transformer)
			value = [transformer reverseTransformedValue:value];
	}

	if (![value isKindOfClass:NSClassFromString([self attributeValueClassName])])
		return nil;

	return value;
}

@end
