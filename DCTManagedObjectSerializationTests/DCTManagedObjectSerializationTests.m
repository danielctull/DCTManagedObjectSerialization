//
//  DCTManagedObjectSerializationTests.m
//  DCTManagedObjectSerializationTests
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTManagedObjectSerializationTests.h"
#import <DCTManagedObjectSerialization/DCTManagedObjectSerialization.h>
#import "Person.h"

@implementation DCTManagedObjectSerializationTests {
	NSManagedObjectContext *_managedObjectContext;
}

- (void)setUp {
    [super setUp];
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleForClass:[self class]]]];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator  alloc] initWithManagedObjectModel:model];
	[psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
	_managedObjectContext = [NSManagedObjectContext new];
	_managedObjectContext.persistentStoreCoordinator = psc;
}

- (void)testManagedObjectContext {
	STAssertNotNil(_managedObjectContext, @"_managedObjectContext is nil.");
	Person *person = [Person insertInManagedObjectContext:_managedObjectContext];
	STAssertNotNil(person, @"_managedObjectContext not set up correctly.");
}

- (void)testObjectCreation {



	NSEntityDescription *entity = [Person entityInManagedObjectContext:_managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															  rootEntity:entity
													managedObjectContext:_managedObjectContext];


	STAssertNotNil(person, @"Not returning an object.");
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (personID = %@).", person.personID);
}

@end
