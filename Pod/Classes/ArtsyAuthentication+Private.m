#import "ArtsyAuthentication+Private.h"

@implementation ArtsyAuthentication (Private)

// Just to silence the compiler warning. 
@dynamic networkOperator;

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback {
    if (callback) {
        callback(token, error);
    }
}

@end
