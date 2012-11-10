//
//  NSEntityDescription+DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (DCTManagedObjectSerialization)

@property (nonatomic, copy) NSArray *dct_serializationUniqueKeys;

@end
