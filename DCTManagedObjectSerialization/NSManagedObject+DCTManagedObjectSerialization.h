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

// Called at end of deserialization. Subclass to tack on additional functionality after calling through to super
- (void)dct_awakeFromDeserialize;

@end
