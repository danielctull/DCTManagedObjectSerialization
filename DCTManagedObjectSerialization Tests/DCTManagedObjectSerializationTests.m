//
//  DCTManagedObjectSerializationTests.m
//  DCTManagedObjectSerializationTests
//
//  Created by Daniel Tull on 10.11.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import XCTest;
#import <DCTManagedObjectSerialization/DCTManagedObjectSerialization.h>
#import "Person.h"
#import "DCTTestNumberToStringValueTransformer.h"

@interface DCTManagedObjectSerializationTests : XCTestCase
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) DCTManagedObjectDeserializer *deserializer;
@property (nonatomic) NSEntityDescription *personEntity;
@end

@implementation DCTManagedObjectSerializationTests

- (void)setUp {
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleForClass:[self class]]]];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator  alloc] initWithManagedObjectModel:model];
	[psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext new];
	managedObjectContext.persistentStoreCoordinator = psc;
	self.managedObjectContext = managedObjectContext;
	self.deserializer = [[DCTManagedObjectDeserializer alloc] initWithManagedObjectContext:managedObjectContext];
	self.personEntity = [Person entityInManagedObjectContext:managedObjectContext];
}

- (void)tearDown {
	self.managedObjectContext = nil;
	self.deserializer = nil;
}

- (void)testBasicObjectCreation {
	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{}];
	XCTAssertNotNil(person, @"person should not be nil.");
	XCTAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}



- (void)testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet {
	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}



- (void)testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary {

	NSAttributeDescription *personIDAttribute = self.personEntity.propertiesByName[PersonAttributes.personID];
	[self.deserializer setSerializationName:@"id" forProperty:personIDAttribute];

	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];

	XCTAssertNotNil(person, @"Person wasn't created");
	XCTAssertNil(person.personID, @"The dictionary doesn't contain the key 'id', so should leave the person in its raw, untouched state");
}



- (void)testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet {

	NSAttributeDescription *personIDAttribute = self.personEntity.propertiesByName[PersonAttributes.personID];
	[self.deserializer setSerializationName:@"id" forProperty:personIDAttribute];

	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ @"id" : @"1" }];

	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet {
	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ @"id" : @"1" }];
	XCTAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingStringAttributeWithNumber {
	NSAttributeDescription *personIDAttribute = self.personEntity.propertiesByName[PersonAttributes.personID];
	[self.deserializer setTransformerNames:@[NSStringFromClass([DCTTestNumberToStringValueTransformer class])] forProperty:personIDAttribute];

	Person *person = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @(1) }];

	XCTAssertNotNil(person, @"Person wasn't created");
	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectDuplication {
	[self.deserializer setUniqueKeys:@[PersonAttributes.personID] forEntity:self.personEntity];

	Person *person1 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];

	XCTAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1, person2);
}

- (void)testObjectDuplicationNotSame {
	[self.deserializer setUniqueKeys:@[PersonAttributes.personID] forEntity:self.personEntity];

	Person *person1 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ @"id" : @"1" }];

	XCTAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1, person2);
}

- (void)testObjectDuplicationNotSame2 {
	[self.deserializer setUniqueKeys:@[PersonAttributes.personID] forEntity:self.personEntity];
	Person *person1 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"2" }];

	XCTAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1, person2);
}

- (void)testObjectDuplication2 {
	Person *person1 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ PersonAttributes.personID : @"1" }];
	XCTAssertFalse([person1 isEqual:person2], @"%@ should not equal %@", person1, person2);
}

- (void)testObjectDuplication3 {
	NSAttributeDescription *personIDAttribute = self.personEntity.propertiesByName[PersonAttributes.personID];
	[self.deserializer setSerializationName:@"id" forProperty:personIDAttribute];
	[self.deserializer setUniqueKeys:@[PersonAttributes.personID] forEntity:self.personEntity];

	Person *person1 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ @"id" : @"1" }];
	Person *person2 = [self.deserializer deserializeObjectWithEntity:self.personEntity fromDictionary:@{ @"id" : @"1" }];

	XCTAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1, person2);
}
@end
