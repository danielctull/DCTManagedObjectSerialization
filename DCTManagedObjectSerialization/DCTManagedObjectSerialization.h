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

@interface DCTManagedObjectSerialization : NSObject

+ (id)objectFromDictionary:(NSDictionary *)dictionary
				rootEntity:(NSEntityDescription *)entity
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
