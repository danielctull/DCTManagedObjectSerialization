
import XCTest
import CoreData
import DCTManagedObjectSerialization

class SerializationInfoTests: XCTestCase {

	var managedObjectModel: NSManagedObjectModel!
	var managedObjectContext: NSManagedObjectContext!
	var serializationInfo: SerializationInfo!

	var tweetEntity: NSEntityDescription {
		return Tweet.entityInManagedObjectContext(managedObjectContext)
	}
	var tweetID: NSPropertyDescription {
		return tweetEntity.attributesByName[TweetAttributes.tweetID as String]!
	}
	var tweetText: NSPropertyDescription {
		return tweetEntity.attributesByName[TweetAttributes.text as String]!
	}

	override func setUp() {
		super.setUp()

		NSValueTransformer.setValueTransformer(URLTransformer(), forName: "URLTransformer")

		let bundle = NSBundle(forClass: self.dynamicType)
		managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([bundle])!
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

		managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
		serializationInfo = SerializationInfo()
	}

	// MARK: No Keys

	// uniqueKeys not set, returns []
	func testNoUniqueKeys() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let uniqueProperties = serializationInfo.uniqueProperties[entity]
		XCTAssertEqual(uniqueProperties.count, 0)
	}

	// shouldDeserializeNilValues not set, returns false
	func testNoShouldDeserializeNilValues() {
		let entity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]
		XCTAssertFalse(shouldDeserializeNilValues)
	}

	// serializationName not set, returns property.name
	func testNoSerializationName() {
		let hashtagEntity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let hashtagName = hashtagEntity.attributesByName[HashtagAttributes.name as String]!
		let serializationName = serializationInfo.serializationName[hashtagName]
		XCTAssertEqual(serializationName, hashtagName.name)
	}

	// transformers not set, returns []
	func testNoTransformerNames() {
		let hashtagEntity = Hashtag.entityInManagedObjectContext(managedObjectContext)
		let hashtagName = hashtagEntity.attributesByName[HashtagAttributes.name as String]!
		let transformers = serializationInfo.transformers[hashtagName]
		XCTAssertEqual(transformers.count, 0)
	}

	// shouldBeUnion not set, returns false
	func testNoShouldBeUnion() {
		let placeEntity = Place.entityInManagedObjectContext(managedObjectContext)
		let placeTweets = placeEntity.relationshipsByName[PlaceRelationships.tweets as String]!
		let shouldBeUnion = serializationInfo.shouldBeUnion[placeTweets]
		XCTAssertFalse(shouldBeUnion)
	}

	// MARK: Setting Keys

	func testSettingUniqueKeys() {
		serializationInfo.uniqueProperties[tweetEntity] = [tweetText]
		let uniqueProperties = serializationInfo.uniqueProperties[tweetEntity]
		XCTAssertEqual(uniqueProperties, [tweetText])
	}

	func testSettingShouldDeserializeNilValues() {
		let entity = Tweet.entityInManagedObjectContext(managedObjectContext)
		serializationInfo.shouldDeserializeNilValues[entity] = true
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[entity]
		XCTAssertTrue(shouldDeserializeNilValues)
	}

	func testSettingSerializationName() {
		let expectedSerializationName = "SerializationName"
		serializationInfo.serializationName[tweetID] = expectedSerializationName
		let serializationName = serializationInfo.serializationName[tweetID]
		XCTAssertEqual(serializationName, expectedSerializationName)
	}

	func testSettingTransformers() {
		let expectedTransformers = [DCTTestNumberToStringValueTransformer()]
		let tweetText = tweetEntity.attributesByName[TweetAttributes.text as String]!
		serializationInfo.transformers[tweetText] = expectedTransformers
		let transformers = serializationInfo.transformers[tweetText]
		XCTAssertEqual(transformers, expectedTransformers)
	}

	func testSettingShouldBeUnion() {
		let userEntity = User.entityInManagedObjectContext(managedObjectContext)
		let userTweets = userEntity.relationshipsByName[UserRelationships.tweets as String]!
		serializationInfo.shouldBeUnion[userTweets] = true
		let shouldBeUnion = serializationInfo.shouldBeUnion[userTweets]
		XCTAssertTrue(shouldBeUnion)
	}

	// MARK: Model Defined Keys

    func testModelDefinedUniqueKeys() {
		let uniqueProperties = serializationInfo.uniqueProperties[tweetEntity]
		XCTAssertEqual(uniqueProperties.count, 1)
		XCTAssertEqual(uniqueProperties[0], tweetID)
    }

	func testModelDefinedSerializationName() {
		let serializationName = serializationInfo.serializationName[tweetID]
		XCTAssertEqual(serializationName, "id_str")
	}

	func testModelDefinedTransformers() {
		let placeEntity = Place.entityInManagedObjectContext(managedObjectContext)
		let placeURL = placeEntity.attributesByName[PlaceAttributes.placeURL as String]!
		let transformers = serializationInfo.transformers[placeURL]
		XCTAssertEqual(transformers.count, 1)
		XCTAssert(transformers[0] as? URLTransformer != nil)
	}

	// MARK: Cross-Context Ability

	func testUniqueKeysTwoContexts() {
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		var serializationInfo = SerializationInfo()

		let managedObjectContext1 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext1.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity1 = Tweet.entityInManagedObjectContext(managedObjectContext1)
		let tweetIDs1 = [tweetEntity1.attributesByName[TweetAttributes.tweetID as String]!]
		serializationInfo.uniqueProperties[tweetEntity1] = tweetIDs1

		let managedObjectContext2 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext2.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity2 = Tweet.entityInManagedObjectContext(managedObjectContext2)
		let tweetIDs2 = serializationInfo.uniqueProperties[tweetEntity2]

		XCTAssertEqual(tweetIDs1.map{ $0.name }, tweetIDs2.map{ $0.name })
	}

	func testShouldDeserializeNilValuesTwoContexts() {
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		var serializationInfo = SerializationInfo()

		let managedObjectContext1 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext1.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity1 = Tweet.entityInManagedObjectContext(managedObjectContext1)
		serializationInfo.shouldDeserializeNilValues[tweetEntity1] = true

		let managedObjectContext2 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext2.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity2 = Tweet.entityInManagedObjectContext(managedObjectContext2)
		let shouldDeserializeNilValues = serializationInfo.shouldDeserializeNilValues[tweetEntity2]

		XCTAssertTrue(shouldDeserializeNilValues)
	}

	func testSerializationNameTwoContexts() {
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		var serializationInfo = SerializationInfo()

		let managedObjectContext1 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext1.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity1 = Tweet.entityInManagedObjectContext(managedObjectContext1)
		let tweetID1 = tweetEntity1.attributesByName[TweetAttributes.tweetID as String]!
		serializationInfo.serializationName[tweetID1] = "NAME"

		let managedObjectContext2 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext2.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity2 = Tweet.entityInManagedObjectContext(managedObjectContext2)
		let tweetID2 = tweetEntity2.attributesByName[TweetAttributes.tweetID as String]!
		let name = serializationInfo.serializationName[tweetID2]

		XCTAssertEqual(name, "NAME")
	}

	func testTransformersTwoContexts() {
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		var serializationInfo = SerializationInfo()
		let expectedTransformers = [DCTTestNumberToStringValueTransformer()]

		let managedObjectContext1 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext1.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity1 = Tweet.entityInManagedObjectContext(managedObjectContext1)
		let tweetID1 = tweetEntity1.attributesByName[TweetAttributes.tweetID as String]!
		serializationInfo.transformers[tweetID1] = expectedTransformers

		let managedObjectContext2 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext2.persistentStoreCoordinator = persistentStoreCoordinator
		let tweetEntity2 = Tweet.entityInManagedObjectContext(managedObjectContext2)
		let tweetID2 = tweetEntity2.attributesByName[TweetAttributes.tweetID as String]!
		let transformers = serializationInfo.transformers[tweetID2]

		XCTAssertEqual(transformers, expectedTransformers)
	}

	func testShouldBeUnionTwoContexts() {

		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		var serializationInfo = SerializationInfo()

		let managedObjectContext1 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext1.persistentStoreCoordinator = persistentStoreCoordinator
		let userEntity1 = User.entityInManagedObjectContext(managedObjectContext1)
		let userTweets1 = userEntity1.relationshipsByName[UserRelationships.tweets as String]!
		serializationInfo.shouldBeUnion[userTweets1] = true

		let managedObjectContext2 = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext2.persistentStoreCoordinator = persistentStoreCoordinator

		let userEntity2 = User.entityInManagedObjectContext(managedObjectContext2)
		let userTweets2 = userEntity2.relationshipsByName[UserRelationships.tweets as String]!
		serializationInfo.shouldBeUnion[userTweets2] = true
		let shouldBeUnion = serializationInfo.shouldBeUnion[userTweets2]

		XCTAssertTrue(shouldBeUnion)
	}
}
