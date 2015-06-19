#import "User.h"

@interface User ()

// Private interface goes here.

@end

@implementation User

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ @%@", self.userID, self.name, self.username];
}

@end
