@import Foundation;

extern NSString* const ArtsyAuthenticationErrorDomain;

typedef enum ArtsyErrorCode {
    ArtsyErrorNoFacebookAppID = 1,
    ArtsyErrorUserDoesNotExist
} ArtsyErrorCode;

@class ArtsyToken, ArtsyAuthenticationRouter;

typedef void (^ArtsyAuthenticationCallback)(ArtsyToken *token, NSError *error);

@interface ArtsyAuthentication : NSObject

/// Create an authentication object
- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

/// Gets a week long trial user token, nil if network errors
- (void)getWeekLongXAppTrialToken:(void (^)(ArtsyToken *token, NSError *error))completion;

/// Gets a 35 year-long authenticated token, nil if network errors
- (void)getUserApplicationXAccessTokenWithEmail:(NSString *)email password:(NSString *)password :(ArtsyAuthenticationCallback)completion;

/// Creates a new user, or fails
- (void)createUserWithUserDictionary:(NSDictionary *)dictionary :(void (^)(NSDictionary *newUserDictionary, NSError *error))completion;

/// Use Stubbed data
@property (nonatomic, assign, readwrite) BOOL stubbedData;

/// Router for generating NSURLRequests
@property (nonatomic, strong, readonly) ArtsyAuthenticationRouter *router;

@end
