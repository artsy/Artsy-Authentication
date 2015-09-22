#import "ArtsyAuthentication+Private.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "ArtsyToken.h"

const void* ArtsyAccountStoreKey = &ArtsyAccountStoreKey;

@implementation ArtsyAuthentication (Private)

// Just to silence the compiler warning. 
@dynamic networkOperator;

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback {
    if (callback) {
        callback(token, error);
    }
}

- (ArtsyNetworkSuccessCallback)successfulLoginBlock:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    return ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSString *token = JSON[ArtsyOAuthTokenKey];
        NSString *expiryDateString = JSON[ArtsyOAuthExpiryKey];
        ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
        NSDate *expiryDate = [dateFormatter dateFromString:expiryDateString];

        ArtsyToken *artsyToken = [[ArtsyToken alloc] initWithToken:token expirationDate:expiryDate];

        [strongSelf callback:artsyToken error:nil completion:callback];
    };
}

- (ArtsyNetworkFailureCallback)failedLoginBlock:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    return ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        // This case handles a 401 from Artsy's server, which means the Facebook account is not associated with a user.
        if (response.statusCode == 401) {
            NSDictionary *userInfo;
            if (error) {
                userInfo = @{ NSUnderlyingErrorKey : error };
            }
            NSError *artsyError = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:ArtsyErrorUserDoesNotExist userInfo:userInfo];

            [strongSelf callback:nil error:artsyError completion:callback];
        } else {
            [strongSelf callback:nil error:error completion:callback];
        }
    };
}

@end
