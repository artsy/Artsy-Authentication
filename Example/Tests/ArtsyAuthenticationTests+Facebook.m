@import Quick;
@import Nimble;
@import Accounts;
@import Social;
@import Artsy_Authentication;
@import ISO8601DateFormatter;
#import <objc/runtime.h>
#import "TestingNetworkOperator.h"

extern const void* ArtsyAccountStoreKey;

@interface ArtsyAuthentication(Test)

- (SLRequest *)requestForMe:(ACAccount *)facebookAccount;

@property (nonatomic, strong) ArtsyNetworkOperator *networkOperator;

@end

@interface StubbedAuthenticator : ArtsyAuthentication
@end

@interface TestingAccountStore : ACAccountStore
@end

@interface TestingResponse : NSHTTPURLResponse
@property (readwrite) NSInteger statusCode;
@end

NSString *authToken = @"token";
NSDate *authExpiryDate;

QuickSpecBegin(ArtsyAuthenticationTests_Facebook)

describe(@"an authentication object", ^{
    NSString *clientID = @"Art5y";
    NSString *clientSecret = @"IActuallyLikeWineCoolers";

    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    authExpiryDate = [dateFormatter dateFromString:@"2045-01-21"];

    TestingResponse *successfulNetworkResponse = [[TestingResponse alloc] init];
    successfulNetworkResponse.statusCode = 200;
    id JSON = @{
        @"access_token" : authToken,
        @"expires_in" : [dateFormatter stringFromDate:authExpiryDate]
    };

    TestingResponse *userDoesNotExistNetworkResponse = [[TestingResponse alloc] init];
    userDoesNotExistNetworkResponse.statusCode = 401;

    __block ArtsyAuthentication *sut;

    beforeEach(^{
        sut = [[StubbedAuthenticator alloc] initWithClientID:clientID clientSecret:clientSecret];
        TestingAccountStore *accountStore = [[TestingAccountStore alloc] init];
        objc_setAssociatedObject(sut, ArtsyAccountStoreKey, accountStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });

    it(@"logs in with Facebook", ^{
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

        __block ArtsyToken *fetchedAuthToken;
        [sut logInWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            fetchedAuthToken = token;
        }];

        expect(fetchedAuthToken.token).toEventually( equal(authToken) );
        expect(fetchedAuthToken.expirationDate).toEventually( equal(authExpiryDate) );
    });

    it(@"creates a user", ^{
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

        __block ArtsyToken *fetchedAuthToken;
        [sut createUserWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            fetchedAuthToken = token;
        }];

        expect(fetchedAuthToken.token).toEventually( equal(authToken) );
        expect(fetchedAuthToken.expirationDate).toEventually( equal(authExpiryDate) );
    });

    it(@"returns correct error for non-existing users", ^{
        NSError *error = [NSError errorWithDomain:@"Zora's Domain" code:0 userInfo:nil];
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:userDoesNotExistNetworkResponse JSON:JSON error:error];

        __block NSError *fetchedError;
        [sut logInWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            fetchedError = error;
        }];

        expect(@(fetchedError.code)).toEventually( equal(@(ArtsyErrorUserDoesNotExist)) );
        expect(fetchedError.domain).toEventually( equal(ArtsyAuthenticationErrorDomain) );
        expect(fetchedError.userInfo[NSUnderlyingErrorKey]).toEventually( equal(error) );
    });
});

QuickSpecEnd

@interface TestingSocialRequest : SLRequest

@end

@implementation TestingSocialRequest

- (instancetype)init {
    /// Note that we're *not* calling super to avoid its pesky assertion failures. 
    return self;
}

- (void)performRequestWithHandler:(SLRequestHandler)handler {
    TestingResponse *response = [[TestingResponse alloc] init];
    response.statusCode = 200;

    id JSON = @{
        @"email" : @"ash@ashfurrow.com",
        @"name" : @"Ash Furrow"
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];

    handler(data, response, nil);
}

@end

@implementation StubbedAuthenticator

- (SLRequest *)requestForMe:(ACAccount *)facebookAccount {
    return [[TestingSocialRequest alloc] init];
}

@end

@interface TestingAccount : ACAccount

@end

@implementation TestingAccount

- (ACAccountCredential *)credential {
    return [[ACAccountCredential alloc] initWithOAuth2Token:@"facebook_token" refreshToken:@"facebook_refresh_token"expiryDate:[NSDate distantFuture]];
}

@end

@implementation TestingAccountStore

- (void)requestAccessToAccountsWithType:(ACAccountType *)accountType options:(NSDictionary *)options completion:(ACAccountStoreRequestAccessCompletionHandler)completion {
    completion(YES, nil);
}

- (NSArray *)accountsWithAccountType:(ACAccountType *)accountType {
    return @[[TestingAccount new]];
}

@end

@implementation TestingResponse

@synthesize statusCode;

@end
