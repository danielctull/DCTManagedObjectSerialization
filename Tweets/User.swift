// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

public struct UserAttributes {
    public static let name = "name"
    public static let userID = "userID"
    public static let username = "username"
}

public struct UserRelationships {
    public static let tweets = "tweets"
}

public struct UserUserInfo {
    public static let uniqueKeys = "uniqueKeys"
}

@objc public
class User: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "User"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = User.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var userID: String?

    // func validateUserID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var username: String?

    // func validateUsername(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var tweets: NSSet

}

extension User {

    func addTweets(objects: NSSet) {
        let mutable = self.tweets.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.tweets = mutable.copy() as! NSSet
    }

    func removeTweets(objects: NSSet) {
        let mutable = self.tweets.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.tweets = mutable.copy() as! NSSet
    }

    func addTweetsObject(value: Tweet!) {
        let mutable = self.tweets.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.tweets = mutable.copy() as! NSSet
    }

    func removeTweetsObject(value: Tweet!) {
        let mutable = self.tweets.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.tweets = mutable.copy() as! NSSet
    }

}

