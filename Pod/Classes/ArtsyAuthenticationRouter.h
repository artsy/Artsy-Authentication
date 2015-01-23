#import <Foundation/Foundation.h>

@class ArtsyToken;

/// Creates NSURLRequests for authentication

@interface ArtsyAuthenticationRouter : NSObject

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

/// Temporary Xapp token for non-logged-in users
- (NSURLRequest *)requestForXapp;

/// Typical Artsy artsy log in
- (NSURLRequest *)requestForAuthWithEmail:(NSString *)email password:(NSString *)password;

/// Artsy new user
- (NSURLRequest *)requestForCreateNewUserwithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password;

/// Log in with Facebook token
- (NSURLRequest *)newFacebookOAuthRequestWithToken:(NSString *)facebookToken;

/// Create new user with Facebook token, email, and name
- (NSURLRequest *)newCreateUserViaFacebookRequestWithToken:(NSString *)facebookToken email:(NSString *)email name:(NSString *)name;

/// Log in with twitter token + secret
- (NSURLRequest *)newTwitterOAuthRequestWithToken:(NSString *)token secret:(NSString *)secret;

/// Create new user with Twitter token, email, and name
- (NSURLRequest *)newCreateUserViaTwitterRequestWithToken:(NSString *)token secret:(NSString *)secret email:(NSString *)email name:(NSString *)name;

/// Switch to staging environment
@property (nonatomic, assign, readwrite) BOOL staging;

@property (readonly, nonatomic, copy) NSString *clientID;
@property (readonly, nonatomic, copy) NSString *clientSecret;

@property (nonatomic, copy) ArtsyToken *xappToken;
@property (nonatomic, copy) ArtsyToken *authToken;

@end
