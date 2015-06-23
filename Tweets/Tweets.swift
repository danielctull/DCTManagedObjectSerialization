
import DCTManagedObjectSerialization
import Foundation


public class Tweets {

	public static func bundle() -> NSBundle {
		return NSBundle(forClass: self)
	}

	public static func importTweets(completion: [AnyObject] -> Void) {

		let queue = dispatch_queue_create("Tweets", nil)
		dispatch_async(queue) {

			let bundle = self.bundle()
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
				let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
				managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

				let deserializer = Deserializer(managedObjectContext: managedObjectContext)

				guard let tweetsArray = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? SerializedArray else {
					return
				}

				let tweetEntity = Tweet.entityInManagedObjectContext(managedObjectContext)
				deserializer.deserializeObjectsWithEntity(tweetEntity, array: tweetsArray, completion: completion)

			} catch {}
		}
	}
}
