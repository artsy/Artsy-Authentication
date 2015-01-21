#import "ArtsyAuthentication.h"

typedef void (^ArtsyAuthenticationFailureCallback)(NSError *error);

@interface ArtsyAuthentication (Facebook)

#pragma mark - User Login

/// Note: You *must* have your main app's Info.plist configured to have
/// the FacebookAppID key set to your app's Facebook ID. If the value
/// cannot be located, callback will be invoked with an NSError having
/// ArtsyErrorNoFacebookAppID code.
- (void)logInWithFacebook:(ArtsyAuthenticationCallback)callback;

/// For errors with ACErrorDomain domain, check ACErrorCode for possible
/// reasons. 
- (void)logInWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback;

#pragma mark - User Creation

- (void)createUserWithFacebook:(ArtsyAuthenticationCallback)callback;

- (void)createUserWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback;

@end
