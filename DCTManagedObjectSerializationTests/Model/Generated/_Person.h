// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>


extern const struct PersonAttributes {
	__unsafe_unretained NSString *personID;
} PersonAttributes;

extern const struct PersonRelationships {
} PersonRelationships;

extern const struct PersonFetchedProperties {
} PersonFetchedProperties;




@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PersonID*)objectID;




@property (nonatomic, strong) NSString* personID;


//- (BOOL)validatePersonID:(id*)value_ error:(NSError**)error_;






@end

@interface _Person (CoreDataGeneratedAccessors)

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePersonID;
- (void)setPrimitivePersonID:(NSString*)value;




@end
