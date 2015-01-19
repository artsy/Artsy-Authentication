#import "ArtsyAuthentication.h"

extern NSString* const ArtsyOAuthTokenKey;
extern NSString* const ArtsyOAuthExpiryKey;
extern NSString* const ArtsyXAppTokenKey;

@interface ArtsyAuthentication (Private)

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback;

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request
                                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
