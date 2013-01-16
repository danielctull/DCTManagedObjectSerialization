//
//  DCTManagedObjectSerializationProperties.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 12.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface NSEntityDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, copy) NSArray *dct_serializationUniqueKeys; // serializationUniqueKeys
@property (nonatomic, assign) BOOL dct_shouldDeserializeNilValues; // shouldDeserializeNilValues (values are "0" for NO or "1" for YES, default is YES)
@end



@interface NSPropertyDescription (DCTManagedObjectSerializationProperties)

@property (nonatomic, copy) NSString *dct_serializationName; // serializationName

// The class that we expect to retreive from a serialized form of the entity. Nil if not suitable for serialization
- (Class)deserializationClass;

@end



@interface NSAttributeDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, copy) NSArray *dct_serializationTransformerNames; // serializationTransformerNames
@end



@interface NSRelationshipDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, assign) BOOL dct_serializationShouldBeUnion; // serializationShouldBeUnion (values are "0" for NO or "1" for YES, default is NO)
@end
