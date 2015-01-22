@import Quick;
@import Nimble;
@import Accounts;
@import Social;
@import Artsy_Authentication;
@import ISO8601DateFormatter;
#import <objc/runtime.h>
#import "TestingNetworkOperator.h"
#import "TestingClasses.h"

QuickSpecBegin(ArtsyAuthenticationTests_Facebook)

__block NSString *authToken = @"token";
__block NSDate *authExpiryDate;

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
        FacebookTestingAccountStore *accountStore = [[FacebookTestingAccountStore alloc] init];
        objc_setAssociatedObject(sut, ArtsyAccountStoreKey, accountStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });

    it(@"logs in with Facebook", ^{
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

        __block ArtsyToken *fetchedAuthToken;
        [sut logInWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            expect(error).to( beNil() );
            fetchedAuthToken = token;
        }];

        expect(fetchedAuthToken.token).to( equal(authToken) );
        expect(fetchedAuthToken.expirationDate).to( equal(authExpiryDate) );
    });

    it(@"creates a user", ^{
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

        __block ArtsyToken *fetchedAuthToken;
        [sut createUserWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            fetchedAuthToken = token;
        }];

        expect(fetchedAuthToken.token).to( equal(authToken) );
        expect(fetchedAuthToken.expirationDate).to( equal(authExpiryDate) );
    });

    it(@"returns correct error for non-existing users", ^{
        NSError *error = [NSError errorWithDomain:@"Zora's Domain" code:0 userInfo:nil];
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:userDoesNotExistNetworkResponse JSON:JSON error:error];

        __block NSError *fetchedError;
        [sut logInWithFacebook:@"1234" completion:^(ArtsyToken *token, NSError *error) {
            fetchedError = error;
        }];

        expect(@(fetchedError.code)).to( equal(@(ArtsyErrorUserDoesNotExist)) );
        expect(fetchedError.domain).to( equal(ArtsyAuthenticationErrorDomain) );
        expect(fetchedError.userInfo[NSUnderlyingErrorKey]).to( equal(error) );
    });
});

QuickSpecEnd

