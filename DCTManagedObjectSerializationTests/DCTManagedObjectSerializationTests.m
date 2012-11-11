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

@implementation DCTManagedObjectSerializationTests

- (NSManagedObjectContext *)newManagedObjectContext {
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleForClass:[self class]]]];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator  alloc] initWithManagedObjectModel:model];
	[psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext new];
	managedObjectContext.persistentStoreCoordinator = psc;
	return managedObjectContext;
}

- (void)testBasicObjectCreation {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	STAssertNotNil(managedObjectContext, @"managedObjectContext is nil.");
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:nil
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertNotNil(person, @"person should not be nil.");
	STAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingStringAttributeWithNumber {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @(1) }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreation222 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSDate *date = [NSDate date];
	NSNumber *timeInterval = @([date timeIntervalSince1970]);
	NSString *dob = [NSString stringWithFormat:@"%@", @([date timeIntervalSince1970])];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1", @"dob" : dob }
															  rootEntity:entity
													managedObjectContext:managedObjectContext];


	STAssertNotNil(person, @"Not returning an object.");
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);

	NSNumber *personTimeInterval = @([person.dateOfBirth timeIntervalSince1970]);
	STAssertTrue([personTimeInterval isEqualToNumber:timeInterval], @"Incorrect dateOfBirth (%@ not %@).", personTimeInterval, timeInterval);
}

- (void)testObjectDuplication {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
															   rootEntity:entity
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															   rootEntity:entity
													 managedObjectContext:managedObjectContext];

	STAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplication2 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															   rootEntity:entity
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
															   rootEntity:entity
													 managedObjectContext:managedObjectContext];

	STAssertFalse([person1 isEqual:person2], @"%@ should not equal %@", person1.objectID, person2.objectID);
}

@end
 