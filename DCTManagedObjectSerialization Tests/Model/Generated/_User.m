// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.name = @"name",
	.userID = @"userID",
	.username = @"username",
};

const struct UserRelationships UserRelationships = {
	.tweets = @"tweets",
};

const struct UserUserInfo UserUserInfo = {
	.uniqueKeys = @"userID",
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic userID;

@dynamic username;

@dynamic tweets;

- (NSMutableSet*)tweetsSet {
	[self willAccessValueForKey:@"tweets"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tweets"];

	[self didAccessValueForKey:@"tweets"];
	return result;
}

@end

