//
//  DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "NSPropertyDescription+DCTManagedObjectSerialization.h"
#import "NSEntityDescription+DCTManagedObjectSerialization.h"

extern NSString *const DCTManagedObjectSerializationSecondsSince1970ValueTransformerName;	// SecondsSince1970ValueTransformer
extern NSString *const DCTManagedObjectSerializationISO8601ValueTransformerName;			// ISO8601ValueTransformer

@interface DCTManagedObjectSerialization : NSObject

+ (id)objectFromDictionary:(NSDictionary *)dictionary
				rootEntity:(NSEntityDescription *)entity
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
