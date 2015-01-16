#import "ArtsyAuthentication.h"

typedef void (^ArtsyAuthenticationFailureCallback)(NSError *error);

@interface ArtsyAuthentication(Facebook)

- (void)logInWithFacebook:(ArtsyAuthenticationCallback)callback;

@end
