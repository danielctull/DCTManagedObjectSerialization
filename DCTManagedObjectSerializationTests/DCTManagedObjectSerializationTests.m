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
#import "DCTTestNumberToStringValueTransformer.h"

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
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertNotNil(person, @"person should not be nil.");
	STAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertNil(person.personID, @"personID should not be set (%@).", person.personID);
}

- (void)testObjectCreationSettingStringAttributeWithNumber {
	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];
	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationTransformerNames = @[NSStringFromClass([DCTTestNumberToStringValueTransformer class])];
	Person *person = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @(1) }
														  rootEntityName:[entity name]
													managedObjectContext:managedObjectContext];
	STAssertTrue([person.personID isEqualToString:@"1"], @"Incorrect personID (%@).", person.personID);
}

- (void)testObjectDuplication {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	STAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplicationNotSame {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	STAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplicationNotSame2 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ PersonAttributes.personID : @"2" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	STAssertFalse([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplication2 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	STAssertFalse([person1 isEqual:person2], @"%@ should not equal %@", person1.objectID, person2.objectID);
}

- (void)testObjectDuplication3 {

	NSManagedObjectContext *managedObjectContext = [self newManagedObjectContext];

	NSEntityDescription *entity = [Person entityInManagedObjectContext:managedObjectContext];
	entity.dct_serializationUniqueKeys = @[PersonAttributes.personID];

	NSAttributeDescription *idAttribute = [[entity propertiesByName] objectForKey:PersonAttributes.personID];
	idAttribute.dct_serializationName = @"id";
	
	Person *person1 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	Person *person2 = [DCTManagedObjectSerialization objectFromDictionary:@{ @"id" : @"1" }
														   rootEntityName:[entity name]
													 managedObjectContext:managedObjectContext];

	STAssertTrue([person1 isEqual:person2], @"%@ should equal %@", person1.objectID, person2.objectID);
}

@end
 