//
//  DCTManagedObjectSerialization.m
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectSerialization.h"
#import "_DCTManagedObjectDeserializer.h"
#import "DCTManagedObjectSerializationProperties.h"

NSString *const DCTManagedObjectSerializationSecondsSince1970ValueTransformerName = @"SecondsSince1970";
NSString *const DCTManagedObjectSerializationISO8601ValueTransformerName = @"ISO8601";

@implementation DCTManagedObjectSerialization

+ (id)objectFromDictionary:(NSDictionary *)dictionary
			rootEntityName:(NSString *)entityName
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	
	_DCTManagedObjectDeserializer *deserializer = [[_DCTManagedObjectDeserializer alloc] initWithDictionary:dictionary
																									 entity:entity
																					   managedObjectContext:managedObjectContext];

	NSManagedObject *result = [deserializer deserializedObject];
	
#if !__has_feature(objc_arc)
	[deserializer release];
#endif
	
    return result;
}

+ (NSString *)serializationDescriptionForEntitiesInManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {

	NSMutableDictionary *entityDictionary = [NSMutableDictionary dictionary];

	[[managedObjectModel entities] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger i, BOOL *stop) {

		NSMutableArray *propertyArray = [NSMutableArray array];

		[entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *property, NSUInteger i, BOOL *stop) {

			NSMutableString *string = [NSMutableString string];
			[string appendFormat:@"%@", property.name];

			NSMutableString *serializationPropertyString = [NSMutableString string];
			[serializationPropertyString appendString:@"("];

			NSString *serializationName = [property.userInfo objectForKey:@"serializationName"];
			if (serializationName) [serializationPropertyString appendFormat:@"serializationName = %@", serializationName];

			if ([property isKindOfClass:[NSRelationshipDescription class]]) {
				NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
				if (relationship.isToMany)
					[serializationPropertyString appendFormat:@"; serializationShouldBeUnion = %@", @(relationship.dct_serializationShouldBeUnion)];
			}

			if ([property isKindOfClass:[NSAttributeDescription class]]) {
				NSAttributeDescription *attribute = (NSAttributeDescription *)property;
				NSArray *serializationTransformerNames = attribute.dct_serializationTransformerNames;
				if (serializationTransformerNames)
					[serializationPropertyString appendFormat:@"; serializationTransformerNames = %@", [serializationTransformerNames componentsJoinedByString:@","]];
			}
			[serializationPropertyString appendString:@")"];

			if (serializationPropertyString.length > 2) [string appendFormat:@" %@", serializationPropertyString];

			[propertyArray addObject:string];
		}];


		NSArray *serializationUniqueKeys = entity.dct_serializationUniqueKeys;
		NSString *entityName = [NSString stringWithFormat:@"%@ (serializationUniqueKeys = %@)", entity.name, serializationUniqueKeys ? [serializationUniqueKeys componentsJoinedByString:@","] : @"none"];
		[entityDictionary setObject:propertyArray forKey:entityName];
	}];
	return [entityDictionary description];
}

@end
