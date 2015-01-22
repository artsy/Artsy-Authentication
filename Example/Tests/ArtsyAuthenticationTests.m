@import Quick;
@import Nimble;
@import Artsy_Authentication;
@import ISO8601DateFormatter;
#import "TestingNetworkOperator.h"

@interface ArtsyAuthentication(Tests)

@property (nonatomic, strong) ArtsyNetworkOperator *networkOperator;

@end

QuickSpecBegin(ArtsyAuthenticationTests)

describe(@"an authentication object", ^{
    NSString *clientID = @"Art5y";
    NSString *clientSecret = @"IActuallyLikeWineCoolers";
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];

    NSString *tokenString = @"token";
    NSDate *expiryDate = [dateFormatter dateFromString:@"2045-01-21"];

    __block ArtsyAuthentication *sut;

    beforeEach(^{
        sut = [[ArtsyAuthentication alloc] initWithClientID:clientID clientSecret:clientSecret];
    });

    it(@"initializes correctly", ^{
        expect(sut.router.clientID).to( equal(clientID) );
        expect(sut.router.clientSecret).to( equal(clientSecret) );
        expect(@(sut.stubbedData)).to( beFalsy() );
    });

    it(@"successfully sets XApp token upon retrieval", ^{

        id JSON = @{
            @"expires_in": [dateFormatter stringFromDate:expiryDate],
            @"xapp_token": tokenString
        };
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:nil JSON:JSON error:nil];

        [sut getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {
            expect(token.token).to( equal(tokenString) );
            expect(token.expirationDate).to( equal(expiryDate) );
        }];

        expect(sut.router.xappToken.token).to( equal(tokenString) );
        expect(sut.router.xappToken.expirationDate).to( equal(expiryDate) );
    });

    it(@"successfully sets Auth token upon login", ^{
        id JSON = @{
            @"expires_in": [dateFormatter stringFromDate:expiryDate],
            @"access_token": tokenString
        };
        sut.networkOperator = [[TestingNetworkOperator alloc] initWithResponse:nil JSON:JSON error:nil];

        [sut logInWithEmail:@"" password:@"" completion:^(ArtsyToken *token, NSError *error) {
            expect(token.token).to( equal(tokenString) );
            expect(token.expirationDate).to( equal(expiryDate) );
        }];

        expect(sut.router.authToken.token).to( equal(tokenString) );
        expect(sut.router.authToken.expirationDate).to( equal(expiryDate) );
    });

    it(@"logs out successfully", ^{
        sut.router.xappToken = [ArtsyToken new];

        [sut logout];
        expect(sut.router.authToken).to( beNil() );
    });
});

QuickSpecEnd
