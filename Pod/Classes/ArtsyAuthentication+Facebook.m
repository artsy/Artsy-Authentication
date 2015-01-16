#import "ArtsyAuthentication+Facebook.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation ArtsyAuthentication (Facebook)

#pragma mark - Public Methods

- (void)logInWithFacebook:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
        allowLoginUI:YES
        completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {

            // Facebook may be calling this block to incidate this session is being closed
            // in favour of another session. We should ignore this case.
            if (status == FBSessionStateClosed) {
                return;
            }

            NSString *token = [[session accessTokenData] accessToken];

            if (!error && token) {
                [[FBRequest requestForMe]
                 startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                     __strong __typeof(weakSelf) strongSelf = self;
                     if (!error) {
                         NSString *email = user[@"email"];
                         NSString *name = user[@"name"];
                         [strongSelf loginToArtsyWithFacebookToken:token email:email name:name completion:callback];
                     } else {
                         // Couldn't get user info from Facebook
                         [strongSelf callback:nil error:error completion:callback];
                     }
                 }];
            } else {
                __strong __typeof(weakSelf) strongSelf = self;
                NSError *callbackError = error ?: [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"Facebook token was nil." }];
                // Couldn't get Facebook credentials
                [strongSelf callback:nil error:callbackError completion:callback];
            }
        }];
}

#pragma mark - Private Methods

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback {
    if (callback) {
        callback(token, error);
    }
}

- (void)loginToArtsyWithFacebookToken:(NSString *)token email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {

}

@end
