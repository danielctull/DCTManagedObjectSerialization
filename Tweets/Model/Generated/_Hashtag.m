// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Hashtag.m instead.

#import "_Hashtag.h"

const struct HashtagAttributes HashtagAttributes = {
	.name = @"name",
};

@implementation HashtagID
@end

@implementation _Hashtag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Hashtag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Hashtag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Hashtag" inManagedObjectContext:moc_];
}

- (HashtagID*)objectID {
	return (HashtagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@end

