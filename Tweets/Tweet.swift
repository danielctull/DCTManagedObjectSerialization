// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tweet.swift instead.

import CoreData

public struct TweetAttributes {
    public static let text = "text"
    public static let tweetID = "tweetID"
}

public struct TweetRelationships {
    public static let place = "place"
    public static let user = "user"
}

public struct TweetUserInfo {
    public static let uniqueKeys = "uniqueKeys"
}

@objc public
class Tweet: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Tweet"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = Tweet.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var text: String?

    // func validateText(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var tweetID: String?

    // func validateTweetID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var place: Place?

    // func validatePlace(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var user: User?

    // func validateUser(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

