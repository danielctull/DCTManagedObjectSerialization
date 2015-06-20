
import XCTest
import CoreData
import DCTManagedObjectSerialization

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
	var deserializer: Deserializer!
	var personID: NSPropertyDescription {
		return personEntity.attributesByName[PersonAttributes.personID as String]!
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
			personEntity = Person.entityInManagedObjectContext(managedObjectContext)
			deserializer = Deserializer(managedObjectContext: managedObjectContext)
		} catch {
			XCTFail()
		}
    }

	func testBasicObjectCreation() {
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: JSONDictionary()) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet() {
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ personID.name : "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let personID = person.personID else {
			XCTFail()
			return
		}
		XCTAssertEqual(personID, "1")
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary() {
		deserializer.info.serializationName[personID] = "id"
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ personID.name : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet() {
		deserializer.info.serializationName[personID] = "id"
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let personID = person.personID else {
			XCTFail()
			return
		}
		XCTAssertEqual(personID, "1")
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet() {
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNil(person.personID)
	}

	func testObjectCreationSettingStringAttributeWithNumber() {
		deserializer.info.transformers[personID] = [DCTTestNumberToStringValueTransformer()]
		guard let person = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : 1 ]) as? Person else {
			XCTFail()
			return
		}
		guard let personID = person.personID else {
			XCTFail()
			return
		}
		XCTAssertEqual(personID, "1")
	}

	func testObjectDuplication() {
		deserializer.info.uniqueProperties[personEntity] = [personID]
		let dictionary = [ personID.name : "1" ]
		guard let person1 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: dictionary) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: dictionary) as? Person else {
			XCTFail()
			return
		}
		XCTAssertEqual(person1, person2)
	}

	func testObjectDuplicationNotSame() {
		deserializer.info.uniqueProperties[personEntity] = [personID]
		guard let person1 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplicationNotSame2() {
		deserializer.info.uniqueProperties[personEntity] = [personID]
		guard let person1 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplication2() {
		guard let person1 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertNotEqual(person1, person2)
	}

	func testObjectDuplication3() {
		deserializer.info.serializationName[personID] = "id"
		deserializer.info.uniqueProperties[personEntity] = [personID]
		guard let person1 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		guard let person2 = deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) as? Person else {
			XCTFail()
			return
		}
		XCTAssertEqual(person1, person2)
	}
}
