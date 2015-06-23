#import "Tweet.h"

@interface Tweet ()
@end

@implementation Tweet

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ (%@)", self.tweetID, self.text, self.user];
}

@end
