
import XCTest
import CoreData
import DCTManagedObjectSerialization

class SerializationInfoTests: XCTestCase {

	var managedObjectContext: NSManagedObjectContext!
	var serializationInfo: SerializationInfo!

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
			serializationInfo = SerializationInfo()
		} catch {
			XCTFail()
		}
	}

	// MARK: No Keys

	// uniqueKeys not set, returns nil
	func testNoUniqueKeys() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let uniqueKeys = serializationInfo.uniqueKeys[entity]
		XCTAssertNil(uniqueKeys)
	}

	// shouldDeserializeNilValues not set, returns false
	func testNoShouldDeserializeNilValues() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		guard let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity] else {
			XCTFail()
			return
		}
		XCTAssertFalse(shouldDeserializeNilValues)
	}

	// serializationName not set, returns property.name
	func testNoSerializationName() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[HashtagAttributes.name as String] else {
			XCTFail()
			return
		}
		guard let serializationName = serializationInfo.serializationName[property] else {
			XCTFail()
			return
		}
		XCTAssertEqual(serializationName, property.name)
	}

	// transformerNames not set, returns nil
	func testNoTransformerNames() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[HashtagAttributes.name as String] else {
			XCTFail()
			return
		}
		let transformerNames = serializationInfo.transformerNames[property]
		XCTAssertNil(transformerNames)
	}

	// shouldBeUnion not set, returns false
	func testNoShouldBeUnion() {
		let entity = Place.entityInManagedObjectContext(managedObjectContext)
		guard let relationship = entity.relationshipsByName[PlaceRelationships.tweets as String] else {
			XCTFail()
			return
		}
		guard let shouldBeUnion = serializationInfo.shouldBeUnion[relationship] else {
			XCTFail()
			return
		}
		XCTAssertFalse(shouldBeUnion)
	}

	// MARK: Setting Keys

	func testSettingUniqueKeys() {
		let expectedUniqueKeys = ["One", "Two"]
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		serializationInfo.uniqueKeys[entity] = expectedUniqueKeys
		guard let uniqueKeys = serializationInfo.uniqueKeys[entity] else {
			XCTFail()
			return
		}
		XCTAssertEqual(uniqueKeys, expectedUniqueKeys)
	}

	func testSettingShouldDeserializeNilValues() {
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		serializationInfo.shouldDeserializeNilValues[entity] = true
		guard let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity] else {
			XCTFail()
			return
		}
		XCTAssertTrue(shouldDeserializeNilValues)
	}

	func testSettingSerializationName() {
		let expectedSerializationName = "SerializationName"
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[TweetAttributes.tweetID as String] else {
			XCTFail()
			return
		}
		serializationInfo.serializationName[property] = expectedSerializationName
		guard let serializationName = serializationInfo.serializationName[property] else {
			XCTFail()
			return
		}
		XCTAssertEqual(serializationName, expectedSerializationName)
	}

	func testSettingTransformerNames() {
		let expectedTransformerNames = ["One", "Two"]
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[TweetAttributes.text as String] else {
			XCTFail()
			return
		}
		serializationInfo.transformerNames[property] = expectedTransformerNames
		guard let transformerNames = serializationInfo.transformerNames[property] else {
			XCTFail()
			return
		}
		XCTAssertEqual(transformerNames, expectedTransformerNames)
	}

	func testSettingShouldBeUnion() {
		let entity = User.entityInManagedObjectContext(managedObjectContext)
		guard let relationship = entity.relationshipsByName[UserRelationships.tweets as String] else {
			XCTFail()
			return
		}
		serializationInfo.shouldBeUnion[relationship] = true
		guard let shouldBeUnion = serializationInfo.shouldBeUnion[relationship] else {
			XCTFail()
			return
		}
		XCTAssertTrue(shouldBeUnion)
	}

	// MARK: Model Defined Keys

    func testModelDefinedUniqueKeys() {
		
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let uniqueKeys = serializationInfo.uniqueKeys[entity] else {
			XCTFail()
			return
		}

		XCTAssertEqual(uniqueKeys.count, 1)
		XCTAssertEqual(uniqueKeys[0], TweetAttributes.tweetID)
    }

	func testModelDefinedSerializationName() {

		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[TweetAttributes.tweetID as String] else {
			XCTFail()
			return
		}
		guard let serializationName = serializationInfo.serializationName[property] else {
			XCTFail()
			return
		}

		XCTAssertEqual(serializationName, "id_str")
	}


	func testModelDefinedTransformerNames() {

		let entity = Place.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[PlaceAttributes.placeURL as String] else {
			XCTFail()
			return
		}
		guard let transformerNames = serializationInfo.transformerNames[property] else {
			XCTFail()
			return
		}

		XCTAssertEqual(transformerNames.count, 1)
		XCTAssertEqual(transformerNames[0], "URLTransformer")
	}
}
