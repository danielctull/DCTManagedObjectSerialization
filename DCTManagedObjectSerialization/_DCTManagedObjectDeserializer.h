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
	NSDictionary *_dictionary;
	NSEntityDescription *_entity;
	NSManagedObjectContext *_managedObjectContext;
	NSDictionary *_serializationNameToPropertyNameMapping;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
				  entity:(NSEntityDescription *)entity
	managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (id)deserializedObject;

@end
