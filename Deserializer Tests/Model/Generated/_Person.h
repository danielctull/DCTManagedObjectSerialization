// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>

extern const struct PersonAttributes {
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *personID;
} PersonAttributes;

extern const struct PersonRelationships {
	__unsafe_unretained NSString *events;
} PersonRelationships;

@class Event;

@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonID* objectID;

@property (nonatomic, strong) NSDate* dateOfBirth;

//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* personID;

//- (BOOL)validatePersonID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;

@end

@interface _Person (EventsCoreDataGeneratedAccessors)
- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;

- (NSString*)primitivePersonID;
- (void)setPrimitivePersonID:(NSString*)value;

- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;

@end
