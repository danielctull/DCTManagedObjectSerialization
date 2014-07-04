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
@end

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
	XCTAssertNotNil(managedObjectContext, @"managedObjectContext is nil.");
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:nil];
	XCTAssertNotNil(person, @"person should not be nil.");
	XCTAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:@{ PersonAttributes.personID : @"1" }];
	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:@{ PersonAttributes.personID : @"1" }];

	XCTAssertNotNil(person, @"Person wasn't created");
	XCTAssertNil(person.personID, @"The dictionary doesn't contain the key 'id', so should leave the person in its raw, untouched state");
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:@{ @"id" : @"1" }];
	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:@{ @"id" : @"1" }];
	XCTAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingStringAttributeWithNumber {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationTransformerNames = @[NSStringFromClass([DCTTestNumberToStringValueTransformer class])];
	Person *person = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															  managedObjectContext:managedObjectContext
																	fromDictionary:@{ PersonAttributes.personID : @(1) }];

	XCTAssertNotNil(person, @"Person wasn't created");
	XCTAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectDuplication {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];
	Person *person1 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ PersonAttributes.personID : @"1" }];

	Person *person2 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ PersonAttributes.personID : @"1" }];

	XCTAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplicationNotSame {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];
	Person *person1 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ @"id" : @"1" }];

	XCTAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplicationNotSame2 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];

	Person *person1 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ PersonAttributes.personID : @"1" }];
	Person *person2 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ PersonAttributes.personID : @"2" }];

	XCTAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplication2 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person1 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ @"id" : @"1" }];
	Person *person2 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ @"id" : @"1" }];

	XCTAssertFalse([person1 isEqual:person2], @"%@ should not equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplication3 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];

	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";

	Person *person1 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ @"id" : @"1" }];

	Person *person2 = [DCTManagedObjectDeserializer deserializeObjectWithEntityName:[entity name]
															   managedObjectContext:managedObjectContext
																	 fromDictionary:@{ @"id" : @"1" }];

	XCTAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}
@end
