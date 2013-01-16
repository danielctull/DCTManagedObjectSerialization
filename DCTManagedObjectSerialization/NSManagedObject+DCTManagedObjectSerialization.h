//
//  NSManagedObject+DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DCTManagedObjectDeserializer.h"

@interface NSManagedObject (DCTManagedObjectSerialization)

- (void)dct_setSerializedValue:(id)object forKey:(NSString *)key;

// Performs deserialization
// You can override to tack on additional functionality *after* calling through to super, although overriding -dct_setSerializedValue:forKey: is often more appropriate
- (void)dct_deserialize:(DCTManagedObjectDeserializer *)deserializier;

@end
