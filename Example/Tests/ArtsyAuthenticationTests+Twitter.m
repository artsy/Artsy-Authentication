@import Quick;
@import Nimble;
@import Artsy_Authentication;
@import ISO8601DateFormatter;
#import "TestingClasses.h"
#import <objc/runtime.h>

QuickSpecBegin(ArtsyAuthenticationTests_Twitter)

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

    __block TwitterTestingAccount *account;
    __block ArtsyAuthentication *sut;

    beforeEach(^{
        account = [TwitterTestingAccount new];
        sut = [[StubbedAuthenticator alloc] initWithClientID:clientID clientSecret:clientSecret];
        TwitterTestingAccountStore *accountStore = [[TwitterTestingAccountStore alloc] init];
        objc_setAssociatedObject(sut, ArtsyAccountStoreKey, accountStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        TestingTwitterReverseAuth *reverseAuth = [[TestingTwitterReverseAuth alloc] init];
        objc_setAssociatedObject(sut, ArtsyTwitterReverseAuthKey, reverseAuth, OBJC_ASSOCIATION_RETAIN);
    });

    describe(@"with no twitter key and no twitter secret", ^{
        it(@"fails ", ^{
            expectAction([sut retrieveTwitterAccounts:nil]).to( raiseException() );
            expectAction([sut createNewUserWithTwitter:account email:@"" name:@"" completion:nil]).to( raiseException() );
            expectAction([sut logInWithTwitterAccount:account completion:nil]).to( raiseException() );
        });
    });

    describe(@"with a twitter key and secret", ^{

        beforeEach(^{
            sut.twitterAPIKey = @"";
            sut.twitterAPISecret = @"";
        });

        it (@"retrieves accounts", ^{
            __block NSArray *fetchedAccounts;

            [sut retrieveTwitterAccounts:^(NSArray *accounts, NSError *error) {
                expect(error).to( beNil() );
                fetchedAccounts = accounts;
            }];

            expect(@([fetchedAccounts.firstObject isKindOfClass:[account class]])).to( beTruthy() );
        });
        
        it(@"logs in with Twitter", ^{
            sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

            __block ArtsyToken *fetchedAuthToken;
            [sut logInWithTwitterAccount:account completion:^(ArtsyToken *token, NSError *error) {
                expect(error).to( beNil() );
                fetchedAuthToken = token;
            }];

            expect(fetchedAuthToken.token).to( equal(authToken) );
            expect(fetchedAuthToken.expirationDate).to( equal(authExpiryDate) );
        });

        it(@"creates a user with Twitter", ^{
            sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:successfulNetworkResponse JSON:JSON error:nil];

            __block ArtsyToken *fetchedAuthToken;
            [sut createNewUserWithTwitter:account email:@"test@example.com" name:@"Mr. Testing" completion:^(ArtsyToken *token, NSError *error) {
                fetchedAuthToken = token;
            }];

            expect(fetchedAuthToken.token).toEventually( equal(authToken) );
            expect(fetchedAuthToken.expirationDate).toEventually( equal(authExpiryDate) );
        });

        it(@"returns correct error for non-existing users", ^{
            NSError *error = [NSError errorWithDomain:@"Zora's Domain" code:0 userInfo:nil];
            sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:userDoesNotExistNetworkResponse JSON:JSON error:error];

            __block NSError *fetchedError;
            [sut logInWithTwitterAccount:account completion:^(ArtsyToken *token, NSError *error) {
                fetchedError = error;
            }];

            expect(@(fetchedError.code)).to( equal(@(ArtsyErrorUserDoesNotExist)) );
            expect(fetchedError.domain).to( equal(ArtsyAuthenticationErrorDomain) );
            expect(fetchedError.userInfo[NSUnderlyingErrorKey]).to( equal(error) );
        });
    });
});

QuickSpecEnd
