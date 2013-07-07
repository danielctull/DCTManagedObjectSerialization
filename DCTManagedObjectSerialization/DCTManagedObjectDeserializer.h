//
//  _DCTManagedObjectDeserializer.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol DCTManagedObjectDeserializerDelegate;

@interface DCTManagedObjectDeserializer : NSObject
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
  @private
	NSDictionary *_dictionary;
	NSManagedObjectContext *_managedObjectContext;
    __weak id <DCTManagedObjectDeserializerDelegate> _delegate;
    
    NSMutableArray  *_errors;

	NSMutableDictionary *_uniqueKeysByEntity;
	NSMutableDictionary *_shouldDeserializeNilValuesByEntity;
	NSMutableDictionary *_serializationNamesByProperty;
	NSMutableDictionary *_transformerNamesByProperty;
	NSMutableDictionary *_serializationShouldBeUnionByRelationship;
#pragma clang diagnostic pop
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((nonnull(1)));

// If there were one or more errors during deserialization, undoes that process, and returns nil
- (id)deserializeObjectWithEntity:(NSEntityDescription *)entity fromDictionary:(NSDictionary *)dictionary __attribute__((nonnull(1,2)));

- (NSArray *)deserializeObjectsWithEntity:(NSEntityDescription *)entity fromArray:(NSArray *)array existingObjectsPredicate:(NSPredicate *)existingObjectsPredicate __attribute__((nonnull(1,2)));

// Convenience to deserialize quickly in one go
+ (id)deserializeObjectWithEntityName:(NSString *)entityName
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       fromDictionary:(NSDictionary *)dictionary;


#pragma mark Properties

#if __has_feature(objc_arc)
@property (nonatomic, weak) id<DCTManagedObjectDeserializerDelegate> delegate;
#else
@property (nonatomic, assign) id<DCTManagedObjectDeserializerDelegate> delegate;
#endif

@property(nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
- (NSArray *)errors;


#pragma mark - Serialization Properties

- (void)setUniqueKeys:(NSArray *)keys forEntity:(NSEntityDescription *)entity;
- (void)setShouldDeserializeNilValues:(NSNumber *)shouldDeserializeNilValues forEntity:(NSEntityDescription *)entity;
- (void)setSerializationName:(NSString *)serializationName forProperty:(NSPropertyDescription *)property;
- (void)setTransformerNames:(NSArray *)transformerNames forProperty:(NSPropertyDescription *)property;
- (void)setSerializationShouldBeUnion:(NSNumber *)serializationShouldBeUnion forRelationship:(NSRelationshipDescription *)relationship;

#pragma mark Debugging
- (NSString *)serializationPropertiesDescription;


@end


@protocol DCTManagedObjectDeserializerDelegate <NSObject>
@optional
- (void)deserializer:(DCTManagedObjectDeserializer *)deserializer didDeserializeObject:(NSManagedObject *)managedObject;
@end

#pragma mark -


@protocol DCTManagedObjectDeserializing <NSObject>

#pragma mark Supplying Your Own Serialized Form

- (id)deserializeObjectWithEntity:(NSEntityDescription *)entity fromDictionary:(NSDictionary *)dictionary __attribute__((nonnull(1,2)));


#pragma mark Deserializing Individual Keys

// Returns nil if the object was found to be of an unsuitable class, recording that as an error (unlike -decodeObjectOfClass:forKey: which throws)
// Also returns nil if the key simply isn't present
// Can use -containsValueForKey: to differentiate between the two
// If key is key path, it will be correctly followed down inside the source serialization
- (id)deserializeObjectOfClass:(Class)class forKey:(NSString *)key __attribute__((nonnull(1,2)));

// Figures out the key and class from the property
- (id)deserializeProperty:(NSPropertyDescription *)property __attribute__((nonnull(1)));

- (NSString *)deserializeStringForKey:(NSString *)key __attribute__((nonnull(1)));

// Generally goes from string form to URL
- (NSURL *)deserializeURLForKey:(NSString *)key __attribute__((nonnull(1)));

- (BOOL)containsValueForKey:(NSString *)key __attribute__((nonnull(1)));

- (id)serializedValueForKey:(NSString *)key __attribute__((nonnull(1)));

#pragma mark Error Reporting

// Takes care of generating an error that references the faulty serialized data
- (void)recordError:(NSError *)error forKey:(NSString *)key __attribute__((nonnull(2)));

// Raw error method
- (void)recordError:(NSError *)error __attribute__((nonnull(1)));

#pragma mark - Serialization Properties

- (NSArray *)uniqueKeysForEntity:(NSEntityDescription *)entity;
- (BOOL)shouldDeserializeNilValuesForEntity:(NSEntityDescription *)entity;
- (NSString *)serializationNameForProperty:(NSPropertyDescription *)property;
- (NSArray *)transformerNamesForProperty:(NSPropertyDescription *)property;
- (BOOL)serializationShouldBeUnionForRelationship:(NSRelationshipDescription *)relationship;


@end
