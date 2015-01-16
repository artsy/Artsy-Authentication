#import "ArtsyAuthentication.h"

typedef void (^ArtsyAuthenticationFailureCallback)(NSError *error);

@interface ArtsyAuthentication (Facebook)

// TODO: Maybe we can get the appID automatically somehow, like the cocoapods plugins idea Orta had. 
- (void)logInWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback;

@end
