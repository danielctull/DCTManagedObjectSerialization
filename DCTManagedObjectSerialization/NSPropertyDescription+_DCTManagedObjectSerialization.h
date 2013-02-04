//
//  NSPropertyDescription+_DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectSerialization.h"


@interface NSPropertyDescription (_DCTManagedObjectSerialization)

// The class that we expect to retreive from a serialized form of the entity. Nil if not suitable for serialization
- (Class)dct_deserializationClassWithDeserializer:(id <DCTManagedObjectDeserializing>)deserializer;

- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer;
- (void)dct_setUserInfoValue:(id)value forKey:(NSString *)key;

@end
