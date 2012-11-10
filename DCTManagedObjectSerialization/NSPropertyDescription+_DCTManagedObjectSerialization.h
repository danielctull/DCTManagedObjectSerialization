//
//  NSPropertyDescription+_DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPropertyDescription (_DCTManagedObjectSerialization)

- (id)dct_valueForSerializedValue:(id)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
