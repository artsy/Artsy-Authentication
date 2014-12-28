#import <Foundation/Foundation.h>

/// Creates NSURLRequests for authentication

@interface ArtsyAuthenticationRouter : NSObject

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

/// Temporary Xapp token for non-logged-in users
- (NSURLRequest *)requestForXapp;

/// Typical Artsy artsy log in
- (NSURLRequest *)requestForAuthWithEmail:(NSString *)email password:(NSString *)password;

/// Log in with facebook token
- (NSURLRequest *)newFacebookOAuthRequestWithToken:(NSString *)token;

/// Log in with twitter token + secret
- (NSURLRequest *)newTwitterOAuthRequestWithToken:(NSString *)token andSecret:(NSString *)secret;

/// Switch to staging environment
@property (nonatomic, assign, readwrite) BOOL staging;

@end
