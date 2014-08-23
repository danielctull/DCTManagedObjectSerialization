//
//  DCTManagedObjectSerializationProperties.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 12.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import Foundation;
@import CoreData;



@interface NSEntityDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, readonly) NSArray *dct_serializationUniqueKeys; // serializationUniqueKeys
@property (nonatomic, readonly) NSNumber *dct_shouldDeserializeNilValues; // shouldDeserializeNilValues (values are "0" for NO or "1" for YES, default is YES)
@end



@interface NSPropertyDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, readonly) NSString *dct_serializationName; // serializationName
@property (nonatomic, readonly) NSArray *dct_serializationTransformerNames; // serializationTransformerNames
@end



@interface NSRelationshipDescription (DCTManagedObjectSerializationProperties)
@property (nonatomic, readonly) NSNumber *dct_serializationShouldBeUnion; // serializationShouldBeUnion (values are "0" for NO or "1" for YES, default is NO)
@end
