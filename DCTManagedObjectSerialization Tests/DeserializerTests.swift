
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
	var personID: NSAttributeDescription {
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
		} catch {
			XCTFail()
		}
    }

	func testBasicObjectCreation() {
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: SerializedDictionary()) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			XCTAssertNil(person.personID)
		}
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileNotHavingSerializationNameSet() {
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ personID.name : "1" ]) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			guard let personID = person.personID else {
				XCTFail()
				return
			}
			XCTAssertEqual(personID, "1")
		}
	}

	func testObjectCreationSettingAttributeWithPropertyNameWhileHavingSerializationNameSetYetProvidingThePropertyNameInTheDictionary() {
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ personID.name : "1" ]) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			XCTAssertNil(person.personID)
		}
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileHavingSerializationNameSet() {
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			guard let personID = person.personID else {
				XCTFail()
				return
			}
			XCTAssertEqual(personID, "1")
		}
	}

	func testObjectCreationSettingAttributeWithSerializationNameWhileNotHavingSerializationNameSet() {
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			XCTAssertNil(person.personID)
		}
	}

	func testObjectCreationSettingStringAttributeWithNumber() {
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		serializationInfo.transformers[personID] = [DCTTestNumberToStringValueTransformer()]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : 1 ]) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			guard let personID = person.personID else {
				XCTFail()
				return
			}
			XCTAssertEqual(personID, "1")
		}
	}

	func testObjectDuplication() {
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		let dictionary = [ personID.name : "1" ]
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: dictionary) { object in
			guard let person1 = object as? Person else {
				XCTFail()
				return
			}
			deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: dictionary) { object in
				guard let person2 = object as? Person else {
					XCTFail()
					return
				}
				XCTAssertEqual(person1, person2)
			}
		}
	}

	func testObjectDuplicationNotSame() {
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) { object in
			guard let person1 = object as? Person else {
				XCTFail()
				return
			}
			deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) { object in
				guard let person2 = object as? Person else {
					XCTFail()
					return
				}
				XCTAssertNotEqual(person1, person2)
			}
		}
	}

	func testObjectDuplicationNotSame2() {
		var serializationInfo = SerializationInfo()
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) { object in
			guard let person1 = object as? Person else {
				XCTFail()
				return
			}
			deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) { object in
				guard let person2 = object as? Person else {
					XCTFail()
					return
				}
				XCTAssertNotEqual(person1, person2)
			}
		}
	}

	func testObjectDuplication2() {
		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ PersonAttributes.personID as String: "1" ]) { object in
			guard let person1 = object as? Person else {
				XCTFail()
				return
			}
			deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ PersonAttributes.personID as String: "2" ]) { object in
				guard let person2 = object as? Person else {
					XCTFail()
					return
				}
				XCTAssertNotEqual(person1, person2)
			}
		}
	}

	func testObjectDuplication3() {
		var serializationInfo = SerializationInfo()
		serializationInfo.serializationName[personID] = "id"
		serializationInfo.uniqueAttributes[personEntity] = [personID]
		let deserializer = Deserializer(managedObjectContext: managedObjectContext, serializationInfo: serializationInfo)
		deserializer.deserializeObjectWithEntity(personEntity, dictionary: [ "id" : "1" ]) { object in
			guard let person1 = object as? Person else {
				XCTFail()
				return
			}
			deserializer.deserializeObjectWithEntity(self.personEntity, dictionary: [ "id" : "1" ]) { object in
				guard let person2 = object as? Person else {
					XCTFail()
					return
				}
				XCTAssertEqual(person1, person2)
			}
		}
	}


	// MARK: Relationships

	func testRelationship() {

		let deserializer = Deserializer(managedObjectContext: managedObjectContext)
		let dictionary = [ PersonAttributes.personID as String : "1", PersonRelationships.events as String : [[ EventAttributes.name as String : "Event" ]] ]

		deserializer.deserializeObjectWithEntity(personEntity, dictionary: dictionary) { object in
			guard let person = object as? Person else {
				XCTFail()
				return
			}
			XCTAssertEqual(person.personID, "1")
			XCTAssertEqual(person.events.count, 1)

			guard let event = person.events.first as? Event else {
				XCTFail()
				return
			}

			XCTAssertEqual(event.name, "Event")
		}
	}
}
