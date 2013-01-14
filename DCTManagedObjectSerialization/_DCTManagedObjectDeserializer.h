//
//  _DCTManagedObjectDeserializer.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface _DCTManagedObjectDeserializer : NSObject
{
  @private
	NSMutableDictionary *_uniqueKeysByEntity;
	NSMutableDictionary *_shouldDeserializeNilValuesByEntity;
	NSMutableDictionary *_serializationNamesByProperty;
	NSMutableDictionary *_transformerNamesByAttribute;
	NSMutableDictionary *_serializationShouldBeUnionByRelationship;
}

- (id)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

- (id)deserializedObjectFromDictionary:(NSDictionary *)dictionary
							rootEntity:(NSEntityDescription *)entity
				  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray *)uniqueKeysForEntity:(NSEntityDescription *)entity;
- (void)setUniqueKeys:(NSArray *)keys forEntity:(NSEntityDescription *)entity;

- (BOOL)shouldDeserializeNilValuesForEntity:(NSEntityDescription *)entity;
- (void)setShouldDeserializeNilValues:(BOOL)shouldDeserializeNilValues forEntity:(NSEntityDescription *)entity;

- (NSString *)serializationNameForProperty:(NSPropertyDescription *)property;
- (void)setSerializationName:(NSString *)serializationName forProperty:(NSPropertyDescription *)property;

- (NSArray *)transformerNamesForAttibute:(NSAttributeDescription *)attribute;
- (void)setTransformerNames:(NSArray *)transformerNames forAttibute:(NSAttributeDescription *)attribute;

- (BOOL)serializationShouldBeUnionForRelationship:(NSRelationshipDescription *)relationship;
- (void)setSerializationShouldBeUnion:(BOOL)serializationShouldBeUnion forRelationship:(NSRelationshipDescription *)relationship;

@end
