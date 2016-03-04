// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.swift instead.

import CoreData

public struct PlaceAttributes {
    public static let country = "country"
    public static let countryCode = "countryCode"
    public static let fullName = "fullName"
    public static let name = "name"
    public static let placeID = "placeID"
    public static let placeType = "placeType"
    public static let placeURL = "placeURL"
}

public struct PlaceRelationships {
    public static let tweets = "tweets"
}

@objc public
class Place: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Place"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = Place.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var country: String?

    // func validateCountry(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var countryCode: String?

    // func validateCountryCode(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var fullName: String?

    // func validateFullName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var placeID: String?

    // func validatePlaceID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var placeType: String?

    // func validatePlaceType(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var placeURL: AnyObject?

    // func validatePlaceURL(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var tweets: NSSet

}

extension Place {

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

