
import XCTest
import CoreData
import Deserializer

func assertOptionalEqual<T: Comparable>(value: T?, expected: T) {
	guard let left = value else {
		XCTFail()
		return
	}
	XCTAssertEqual(left, expected)
}

class DeserializerTests: XCTestCase {

	var managedObjectContext: NSManagedObjectContext!
	var personEntity: NSEntityDescription!
	var eventEntity: NSEntityDescription!
	var personID: NSAttributeDescription {
		return personEntity.attributesByName["personID"]!
	}

    override func setUp() {
        super.setUp()
		
		let bundle = NSBundle(forClass: self.dynamicType)
		guard let model = NSManagedObjectModel.mergedModelFromBundles([bundle]) else {
			XCTFail()
			return
		}

		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

		do {
			try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
			managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
			personEntity = Person.entity(managedObjectContext)
			eventEntity = Event.entity(managedObjectContext)
		} catch {
			XCTFail()
		}
    }

	func testBasicObjectCreation() {
		let expectation = self.expectationWithDescription("testBasicObjectCreation")
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserialize(entity: personEntity, dictionary: SerializedDictionary()) { (person: Person?) in
			XCTAssertNotNil(person)
			XCTAssertNil(person?.personID)
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet() {
		let expectation = self.expectationWithDescription("testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet")
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserialize(entity: personEntity, dictionary: [ personID.name : "1" ]) { (person: Person?) in
			defer { expectation.fulfill() }
			XCTAssertNotNil(person)
			XCTAssertNotNil(person?.personID)
			XCTAssertEqual(person?.personID, "1")
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary() {
		let expectation = self.expectationWithDescription("testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary")
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ personID.name : "1" ]) { (person: Person?) in
			XCTAssertNotNil(person)
			XCTAssertNil(person?.personID)
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet() {
		let expectation = self.expectationWithDescription("testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet")
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ "id" : "1" ]) { (person: Person?) in
			XCTAssertNotNil(person)
			XCTAssertEqual(person?.personID, "1")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}

	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet() {
		let expectation = self.expectationWithDescription("testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet")
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserialize(entity: personEntity, dictionary: [ "id" : "1" ]) { (person: Person?) in
			XCTAssertNotNil(person)
			XCTAssertNil(person?.personID)
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectCreationSettingStringAttributeWithNumber() {
		let expectation = self.expectationWithDescription("testObjectCreationSettingStringAttributeWithNumber")
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		serializationInfo.transformers[personID] = [NumberToStringValueTransformer()]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ "id" : 1 ]) { (person: Person?) in
			XCTAssertNotNil(person)
			XCTAssertEqual(person?.personID, "1")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectDuplication() {
		let expectation = self.expectationWithDescription("testObjectDuplication")
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		let dictionary = [ personID.name : "1" ]
		deserializer.deserialize(entity: personEntity, dictionary: dictionary) { (person1: Person?) in
			deserializer.deserialize(entity: self.personEntity, dictionary: dictionary) { (person2: Person?) in
				XCTAssertNotNil(person1)
				XCTAssertNotNil(person2)
				XCTAssertEqual(person1, person2)
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectDuplicationNotSame() {
		let expectation = self.expectationWithDescription("testObjectDuplicationNotSame")
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ personID.name : "1" ]) { (person1: Person?) in
			deserializer.deserialize(entity: self.personEntity, dictionary: [ "id" : "1" ]) { (person2: Person?) in
				XCTAssertNotNil(person1)
				XCTAssertNotNil(person2)
				XCTAssertNotEqual(person1, person2)
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectDuplicationNotSame2() {
		let expectation = self.expectationWithDescription("testObjectDuplicationNotSame2")
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ personID.name : "1" ]) { (person1: Person?) in
			deserializer.deserialize(entity: self.personEntity, dictionary: [ self.personID.name : "2" ]) { (person2: Person?) in
				XCTAssertNotNil(person1)
				XCTAssertNotNil(person2)
				XCTAssertNotEqual(person1, person2)
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectDuplication2() {
		let expectation = self.expectationWithDescription("testObjectDuplication2")
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserialize(entity: personEntity, dictionary: [ personID.name : "1" ]) { (person1: Person?) in
			deserializer.deserialize(entity: self.personEntity, dictionary: [ self.personID.name : "2" ]) { (person2: Person?) in
				XCTAssertNotNil(person1)
				XCTAssertNotNil(person2)
				XCTAssertNotEqual(person1, person2)
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	func testObjectDuplication3() {
		let expectation = self.expectationWithDescription("testObjectDuplication3")
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserialize(entity: personEntity, dictionary: [ "id" : "1" ]) { (person1: Person?) in
			deserializer.deserialize(entity: self.personEntity, dictionary: [ "id" : "1" ]) { (person2: Person?) in
				XCTAssertNotNil(person1)
				XCTAssertNotNil(person2)
				XCTAssertEqual(person1, person2)
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(30) { error in
			XCTAssertNil(error)
		}
	}

	// MARK: Relationships

//	func testRelationship() {
//		let expectation = self.expectationWithDescription("testRelationship")
//		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
//		let dictionary = [ personID.name : "1", PersonRelationships.events as String : [[ EventAttributes.name as String : "Party!" ]] ]
//		deserializer.deserialize(entity: personEntity, dictionary: dictionary) { object in
//			defer {	expectation.fulfill() }
//			guard let person = object as? Person else {
//				XCTFail()
//				return
//			}
//			guard let personID = person.personID else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(personID, "1")
//			XCTAssertEqual(person.events.count, 1)
//			guard let event = person.events.first as? Event else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(event.name, "Party!")
//		}
//		waitForExpectationsWithTimeout(30) { error in
//			XCTAssertNil(error)
//		}
//	}
//
//	func testRelationship2() {
//		let expectation = self.expectationWithDescription("testRelationship2")
//		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
//		let dictionary = [ EventAttributes.name as String : "Party!", EventRelationships.person as String : [ PersonAttributes.personID as String : "1" ] ]
//		deserializer.deserialize(entity: eventEntity, dictionary: dictionary) { object in
//			defer {	expectation.fulfill() }
//			guard let event = object as? Event else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(event.name, "Party!")
//			guard let person = event.person else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(person.events.count, 1)
//			guard let personID = person.personID else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(personID, "1")
//		}
//		waitForExpectationsWithTimeout(30) { error in
//			XCTAssertNil(error)
//		}
//	}
//
//	func testRelationshipDuplicate() {
//		let expectation = self.expectationWithDescription("testRelationship2")
//		var serializationInfo = SerializationInfo()
//		serializationInfo.uniqueAttributes[personEntity] = [personID]
//		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
//		let personDictionary = [ PersonAttributes.personID as String : "1" ]
//		let event1Dictionary: SerializedDictionary = [ EventAttributes.name as String : "Party 1!", EventRelationships.person as String : personDictionary ]
//		let event2Dictionary: SerializedDictionary = [ EventAttributes.name as String : "Party 2!", EventRelationships.person as String : personDictionary ]
//		let array = [ event1Dictionary, event2Dictionary ]
//		deserializer.deserialize(entity: eventEntity, array: array) { objects in
//
//			defer {	expectation.fulfill() }
//
//			XCTAssertEqual(objects.count, 2)
//
//			guard let events = objects as? [Event] else {
//				XCTFail()
//				return
//			}
//			let event1 = events[0]
//			let event2 = events[1]
////			XCTAssertEqual(event1.name, "Party 1!")
////			XCTAssertEqual(event2.name, "Party 2!")
//			guard let person1 = event1.person else {
//				XCTFail()
//				return
//			}
//			guard let person2 = event2.person else {
//				XCTFail()
//				return
//			}
//			XCTAssertEqual(person1.personID, "1")
//			XCTAssertEqual(person2.personID, "1")
//			XCTAssertEqual(person1, person2)
//		}
//
//		waitForExpectationsWithTimeout(30) { error in
//			XCTAssertNil(error)
//		}
//	}

}
