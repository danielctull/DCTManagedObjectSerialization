//
//  NSManagedObject+DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import CoreData;
@protocol DCTManagedObjectDeserializing;

@interface NSManagedObject (DCTManagedObjectSerialization)

// Override in your custom classes to ignore certain properties, or do custom deserialization
// Default implementation calls [deserializer deserializeProperty:], checks the result is valid, and applies (using primitive setter method for attributes)
- (void)dct_deserializeProperty:(NSPropertyDescription *)property withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer __attribute__((nonnull(1,2)));

// Performs deserialization
// You can override to tack on additional functionality *after* calling through to super, although overriding -dct_deserializeProperty:withDeserializer: is often more appropriate
- (void)dct_deserialize:(id <DCTManagedObjectDeserializing>)deserializier;

@end
