// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tweet.h instead.

#import <CoreData/CoreData.h>

extern const struct TweetAttributes {
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *tweetID;
} TweetAttributes;

extern const struct TweetRelationships {
	__unsafe_unretained NSString *place;
	__unsafe_unretained NSString *user;
} TweetRelationships;

extern const struct TweetUserInfo {
	__unsafe_unretained NSString *uniqueKeys;
} TweetUserInfo;

@class Place;
@class User;

@interface TweetID : NSManagedObjectID {}
@end

@interface _Tweet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TweetID* objectID;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* tweetID;

//- (BOOL)validateTweetID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Place *place;

//- (BOOL)validatePlace:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _Tweet (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSString*)primitiveTweetID;
- (void)setPrimitiveTweetID:(NSString*)value;

- (Place*)primitivePlace;
- (void)setPrimitivePlace:(Place*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
