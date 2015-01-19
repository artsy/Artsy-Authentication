#import "ArtsyAuthentication.h"

extern NSString* const ArtsyOAuthTokenKey;
extern NSString* const ArtsyOAuthExpiryKey;

@interface ArtsyAuthentication (Private)

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback;

@end
