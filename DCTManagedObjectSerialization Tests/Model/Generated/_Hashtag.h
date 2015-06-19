// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Hashtag.h instead.

#import <CoreData/CoreData.h>

extern const struct HashtagAttributes {
	__unsafe_unretained NSString *name;
} HashtagAttributes;

@interface HashtagID : NSManagedObjectID {}
@end

@interface _Hashtag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HashtagID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@end

@interface _Hashtag (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

@end
