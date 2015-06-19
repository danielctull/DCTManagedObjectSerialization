// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.m instead.

#import "_Place.h"

const struct PlaceAttributes PlaceAttributes = {
	.country = @"country",
	.countryCode = @"countryCode",
	.fullName = @"fullName",
	.name = @"name",
	.placeID = @"placeID",
	.placeType = @"placeType",
	.placeURL = @"placeURL",
};

const struct PlaceRelationships PlaceRelationships = {
	.tweets = @"tweets",
};

@implementation PlaceID
@end

@implementation _Place

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Place";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc_];
}

- (PlaceID*)objectID {
	return (PlaceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic country;

@dynamic countryCode;

@dynamic fullName;

@dynamic name;

@dynamic placeID;

@dynamic placeType;

@dynamic placeURL;

@dynamic tweets;

- (NSMutableSet*)tweetsSet {
	[self willAccessValueForKey:@"tweets"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tweets"];

	[self didAccessValueForKey:@"tweets"];
	return result;
}

@end

