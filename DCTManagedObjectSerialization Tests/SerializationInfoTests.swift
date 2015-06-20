
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

	// uniqueKeys not set, returns []
	func testNoUniqueKeys() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let uniqueKeys = serializationInfo.uniqueKeys[entity]
		XCTAssertEqual(uniqueKeys.count, 0)
	}

	// shouldDeserializeNilValues not set, returns false
	func testNoShouldDeserializeNilValues() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]
		XCTAssertFalse(shouldDeserializeNilValues)
	}

	// serializationName not set, returns property.name
	func testNoSerializationName() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[HashtagAttributes.name as String] else {
			XCTFail()
			return
		}
		let serializationName = serializationInfo.serializationName[property]
		XCTAssertEqual(serializationName, property.name)
	}

	// transformers not set, returns []
	func testNoTransformerNames() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[HashtagAttributes.name as String] else {
			XCTFail()
			return
		}
		let transformers = serializationInfo.transformers[property]
		XCTAssertEqual(transformers.count, 0)
	}

	// shouldBeUnion not set, returns false
	func testNoShouldBeUnion() {
		let entity = Place.entityInManagedObjectContext(managedObjectContext)
		guard let relationship = entity.relationshipsByName[PlaceRelationships.tweets as String] else {
			XCTFail()
			return
		}
		let shouldBeUnion = serializationInfo.shouldBeUnion[relationship]
		XCTAssertFalse(shouldBeUnion)
	}

	// MARK: Setting Keys

	func testSettingUniqueKeys() {
		let expectedUniqueKeys = ["One", "Two"]
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		serializationInfo.uniqueKeys[entity] = expectedUniqueKeys
		let uniqueKeys = serializationInfo.uniqueKeys[entity]
		XCTAssertEqual(uniqueKeys, expectedUniqueKeys)
	}

	func testSettingShouldDeserializeNilValues() {
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		serializationInfo.shouldDeserializeNilValues[entity] = true
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]
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
		let serializationName = serializationInfo.serializationName[property]
		XCTAssertEqual(serializationName, expectedSerializationName)
	}

	func testSettingTransformers() {
		let expectedTransformers = [DCTTestNumberToStringValueTransformer()]
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[TweetAttributes.text as String] else {
			XCTFail()
			return
		}
		serializationInfo.transformers[property] = expectedTransformers
		let transformers = serializationInfo.transformers[property]
		XCTAssertEqual(transformers, expectedTransformers)
	}

	func testSettingShouldBeUnion() {
		let entity = User.entityInManagedObjectContext(managedObjectContext)
		guard let relationship = entity.relationshipsByName[UserRelationships.tweets as String] else {
			XCTFail()
			return
		}
		serializationInfo.shouldBeUnion[relationship] = true
		let shouldBeUnion = serializationInfo.shouldBeUnion[relationship]
		XCTAssertTrue(shouldBeUnion)
	}

	// MARK: Model Defined Keys

    func testModelDefinedUniqueKeys() {
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		let uniqueKeys = serializationInfo.uniqueKeys[entity]
		XCTAssertEqual(uniqueKeys.count, 1)
		XCTAssertEqual(uniqueKeys[0], TweetAttributes.tweetID)
    }

	func testModelDefinedSerializationName() {

		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[TweetAttributes.tweetID as String] else {
			XCTFail()
			return
		}
		let serializationName = serializationInfo.serializationName[property]
		XCTAssertEqual(serializationName, "id_str")
	}

	func testModelDefinedTransformerNames() {

		let entity = Place.entityInManagedObjectContext(managedObjectContext)
		guard let property = entity.attributesByName[PlaceAttributes.placeURL as String] else {
			XCTFail()
			return
		}
		let transformers = serializationInfo.transformers[property]
		XCTAssertEqual(transformers.count, 1)
//		XCTAssert(transformers[0].isKindOfClass(URLTransformer.dynamicType))
	}
}
