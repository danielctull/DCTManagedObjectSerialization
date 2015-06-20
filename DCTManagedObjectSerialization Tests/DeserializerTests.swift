
import XCTest
import CoreData
import DCTManagedObjectSerialization

class DeserializerTests: XCTestCase {

	var managedObjectContext: NSManagedObjectContext!
	var personEntity: NSEntityDescription!
	var deserializer: Deserializer!

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
			personEntity = Person.entityInManagedObjectContext(managedObjectContext)
			deserializer = Deserializer(managedObjectContext: managedObjectContext)
		} catch {
			XCTFail()
		}
    }

	func testBascObjectCreation() {
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: JSONDictionary()) else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet() {
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) else {
			XCTFail()
			return
		}
		XCTAssertEqual(person.personID, "1")
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary() {
		guard let property = self.personEntity.attributesByName[PersonAttributes.personID as String] else {
			XCTFail()
			return
		}
		self.deserializer.info.serializationName[property] = "id"
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet() {
		guard let property = self.personEntity.attributesByName[PersonAttributes.personID as String] else {
			XCTFail()
			return
		}
		self.deserializer.info.serializationName[property] = "id"
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) else {
			XCTFail()
			return
		}
		XCTAssertEqual(person.personID, "1")
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet() {
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingStringAttributeWithNumber() {
		guard let property = self.personEntity.attributesByName[PersonAttributes.personID as String] else {
			XCTFail()
			return
		}
		self.deserializer.info.transformerNames[property] = ["DCTTestNumberToStringValueTransformer"]
		guard let person = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : 1 ]) else {
			XCTFail()
			return
		}
		XCTAssertEqual(person.personID, "1")
	}

	func testObjectDuplication() {
		self.deserializer.info.uniqueKeys[self.personEntity] = [PersonAttributes.personID as String]
		let dictionary = [ PersonAttributes.personID as String : "1" ]
		guard let person1 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: dictionary) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: dictionary) as? Person else {
			XCTFail()
			return
		}
		XCTAssertEqual(person1, person2)
	}

	func testObjectDuplicationNotSame() {
		self.deserializer.info.uniqueKeys[self.personEntity] = [PersonAttributes.personID as String]
		guard let person1 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplicationNotSame2() {
		self.deserializer.info.uniqueKeys[self.personEntity] = [PersonAttributes.personID as String]
		guard let person1 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplication2() {
		guard let person1 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplication3() {
		guard let property = self.personEntity.attributesByName[PersonAttributes.personID as String] else {
			XCTFail()
			return
		}
		self.deserializer.info.serializationName[property] = "id"
		self.deserializer.info.uniqueKeys[self.personEntity] = [PersonAttributes.personID as String]
		guard let person1 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = self.deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertEqual(person1, person2)
	}
}
