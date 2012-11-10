//
//  NSManagedObject+DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DCTManagedObjectSerialization)

- (void)dct_setSerializedValue:(id)object forKey:(NSString *)key;

@end
