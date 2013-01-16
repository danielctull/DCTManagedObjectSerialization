//
//  _DCTManagedObjectDeserializer.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DCTManagedObjectDeserializer : NSObject
{
  @private
	NSDictionary *_dictionary;
	NSEntityDescription *_entity;
	NSManagedObjectContext *_managedObjectContext;
	NSDictionary *_serializationNameToPropertyNameMapping;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
				  entity:(NSEntityDescription *)entity
	managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// Returns nil if the object was found to be of an unsuitable class (unlike -decodeObjectOfClass:forKey: which throws)
// Also returns nil if the key simply isn't present
// Can use -containsValueForKey: to differentiate between the two
// If key is key path, it will be correctly followed down inside the source serialization
- (id)deserializeObjectOfClass:(Class)class forKey:(NSString *)key __attribute__((nonnull(1,2)));

// Generally goes from string form to URL
- (NSURL *)deserializeURLForKey:(NSString *)key __attribute__((nonnull(1)));

- (BOOL)containsValueForKey:(NSString *)key __attribute__((nonnull(1)));


- (id)deserializedObject;

@end
