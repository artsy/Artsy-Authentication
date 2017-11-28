#import <Foundation/Foundation.h>

extern NSString* const ArtsyAuthenticationErrorDomain;

typedef enum ArtsyErrorCode {
    ArtsyErrorNoFacebookAppID = 1,
    ArtsyErrorUserDoesNotExist
} ArtsyErrorCode;

@class ArtsyToken, ArtsyAuthenticationRouter;

typedef void (^ArtsyAuthenticationCallback)(ArtsyToken *token, NSError *error);
typedef void (^ArtsyAuthenticationWithUserDetailsCallback)(ArtsyToken *token, NSDictionary *userDetails, NSError *error);

@interface ArtsyAuthentication : NSObject

/// Create an authentication object
- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

/// Gets a week long trial user token, nil if network errors
- (void)getWeekLongXAppTrialToken:(ArtsyAuthenticationCallback)completion;

/// Gets a 35 year-long authenticated token, nil if network errors
- (void)logInWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(ArtsyAuthenticationCallback)completion;

/// Gets a 35 year-long authenticated token, nil if network errors, and in addition fetches the user’s details
- (void)logInAndFetchUserDetailsWithEmail:(NSString *)email
                                 password:(NSString *)password
                               completion:(ArtsyAuthenticationWithUserDetailsCallback)completion;

/// Creates a new user, or fails
- (void)createUserWithEmail:(NSString *)email
                       name:(NSString *)name
                   password:(NSString *)password
                 completion:(void (^)(NSDictionary *newUserDictionary, NSError *error))completion;

/// Clears any user auth token from the router.
- (void)logout;

/// Use Stubbed data
@property (nonatomic, assign, readwrite) BOOL stubbedData;

/// Router for generating NSURLRequests
@property (nonatomic, strong, readonly) ArtsyAuthenticationRouter *router;

@end
