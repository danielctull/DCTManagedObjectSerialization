// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.h instead.

#import <CoreData/CoreData.h>

extern const struct PlaceAttributes {
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *countryCode;
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *placeID;
	__unsafe_unretained NSString *placeType;
	__unsafe_unretained NSString *placeURL;
} PlaceAttributes;

extern const struct PlaceRelationships {
	__unsafe_unretained NSString *tweets;
} PlaceRelationships;

@class Tweet;

@class NSObject;

@interface PlaceID : NSManagedObjectID {}
@end

@interface _Place : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PlaceID* objectID;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* countryCode;

//- (BOOL)validateCountryCode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fullName;

//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* placeID;

//- (BOOL)validatePlaceID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* placeType;

//- (BOOL)validatePlaceType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id placeURL;

//- (BOOL)validatePlaceURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *tweets;

- (NSMutableSet*)tweetsSet;

@end

@interface _Place (TweetsCoreDataGeneratedAccessors)
- (void)addTweets:(NSSet*)value_;
- (void)removeTweets:(NSSet*)value_;
- (void)addTweetsObject:(Tweet*)value_;
- (void)removeTweetsObject:(Tweet*)value_;

@end

@interface _Place (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;

- (NSString*)primitiveCountryCode;
- (void)setPrimitiveCountryCode:(NSString*)value;

- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePlaceID;
- (void)setPrimitivePlaceID:(NSString*)value;

- (NSString*)primitivePlaceType;
- (void)setPrimitivePlaceType:(NSString*)value;

- (id)primitivePlaceURL;
- (void)setPrimitivePlaceURL:(id)value;

- (NSMutableSet*)primitiveTweets;
- (void)setPrimitiveTweets:(NSMutableSet*)value;

@end
