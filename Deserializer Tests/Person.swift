// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.swift instead.

import CoreData

public struct PersonAttributes {
    static let dateOfBirth = "dateOfBirth"
    static let personID = "personID"
}

public struct PersonRelationships {
    static let events = "events"
}

@objc public
class Person: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Person"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = Person.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var dateOfBirth: NSDate?

    // func validateDateOfBirth(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var personID: String?

    // func validatePersonID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var events: Set<Event>

}
