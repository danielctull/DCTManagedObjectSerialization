
import DCTManagedObjectSerialization
import Foundation


public class Tweets {

	public static func bundle() -> NSBundle {
		return NSBundle(forClass: self)
	}

	public static func importTweets(completion: [AnyObject] -> Void) {

		let bundle = NSBundle(forClass: self)
		guard let model = NSManagedObjectModel.mergedModelFromBundles([bundle]) else {
			return
		}

		guard let tweetsURL = bundle.URLForResource("Tweets", withExtension: "json") else {
			return
		}

		guard let data = NSData(contentsOfURL: tweetsURL) else {
			return
		}

		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

		do {
			try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
			let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

			let deserializer = Deserializer(managedObjectContext: managedObjectContext)

			guard let tweetsArray = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? SerializedArray else {
				return
			}

			let tweetEntity = Tweet.entityInManagedObjectContext(managedObjectContext)

			//				let objects = deserializer.deserializeObjectsWithEntity(tweetEntity, fromArray: tweetsArray, existingObjectsPredicate: nil)

			deserializer.deserializeObjectsWithEntity(tweetEntity, array: tweetsArray, completion: completion)
			//				print((objects as NSArray).componentsJoinedByString("\n\n\n"))

		} catch {
		}
	}
}
