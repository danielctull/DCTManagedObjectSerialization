//
//  _DCTManagedObjectDeserializer.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@protocol DCTManagedObjectDeserializing <NSObject>

#pragma mark Deserializing a Whole Dictionary

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


#pragma mark Error Reporting

// Takes care of generating an error that references the faulty serialized data
- (void)recordError:(NSError *)error forKey:(NSString *)key __attribute__((nonnull(2)));

// Raw error methods
- (void)recordError:(NSError *)error __attribute__((nonnull(1)));


@end


#pragma mark -


@interface DCTManagedObjectDeserializer : NSObject <DCTManagedObjectDeserializing>
{
  @private
	NSDictionary *_dictionary;
	NSEntityDescription *_entity;
	NSManagedObjectContext *_managedObjectContext;
	NSDictionary *_serializationNameToPropertyNameMapping;
    
    NSMutableArray  *_errors;
}

// Convenience to deserialize quickly in one go
+ (id)deserializeObjectWithEntityName:(NSString *)entityName
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       fromDictionary:(NSDictionary *)dictionary;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((nonnull(1)));

- (NSArray *)errors;


@end
