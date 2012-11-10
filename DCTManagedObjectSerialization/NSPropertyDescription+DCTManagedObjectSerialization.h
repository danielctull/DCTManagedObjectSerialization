//
//  NSPropertyDescription+DCTManagedObjectSerialization.h
//  DCTManagedObjectSerialization
//
//  Created by Daniel Tull on 10/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPropertyDescription (DCTManagedObjectSerialization)

@property (nonatomic, copy) NSString *dct_serializationName;
@property (nonatomic, copy) Class dct_serializationTransformerClass;

@end
