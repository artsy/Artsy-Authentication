#import "ArtsyAuthentication+Private.h"

@implementation ArtsyAuthentication (Private)

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback {
    if (callback) {
        callback(token, error);
    }
}

@end
