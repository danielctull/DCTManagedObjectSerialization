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

	__block id transformedValue = value;

	NSArray *transformerNames = self.dct_serializationTransformerNames;
	[transformerNames enumerateObjectsUsingBlock:^(NSString *transformerName, NSUInteger idx, BOOL *stop) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:transformerName];
		transformedValue = [transformer transformedValue:transformedValue];
	}];

	Class attributeClass = NSClassFromString([self attributeValueClassName]);

	if ([transformedValue isKindOfClass:attributeClass])
		return transformedValue;

	if ([value isKindOfClass:attributeClass])
			return value;

	return nil;
}

@end
