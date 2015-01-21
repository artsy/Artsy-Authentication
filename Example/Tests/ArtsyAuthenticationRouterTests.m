@import Quick;
@import Nimble;
@import Artsy_Authentication;
@import NSURL_QueryDictionary;
@import OHHTTPStubs;

@interface ArtsyAuthenticationRouter(Tests)

- (NSURL *)urlWithPath:(NSString *)path;
- (NSURLRequest *)baseRequestForAddress:(NSURL *)url;
- (NSURLRequest *)baseRequestForAddress:(NSURL *)url method:(NSString *)httpMethod;

@end

QuickSpecBegin(ArtsyAuthenticationRouterSpec)

describe(@"a router", ^{
    NSString *clientID = @"Art5y";
    NSString *clientSecret = @"IActuallyLikeWineCoolers";
    NSString *xappToken = @"";
    NSDate *tokenExpirationDate = [NSDate distantFuture];

    __block ArtsyAuthenticationRouter *sut = nil;

    beforeEach(^{
        sut = [[ArtsyAuthenticationRouter alloc] initWithClientID:clientID clientSecret:clientSecret];
        sut.xappToken = [[ArtsyToken alloc] initWithToken:xappToken expirationDate:tokenExpirationDate];
    });

    it(@"initializes correctly", ^{
        expect(sut.clientID).to( equal(clientID) );
        expect(sut.clientSecret).to( equal(clientSecret) );
        expect(sut.xappToken.token).to( equal(xappToken) );
        expect(sut.xappToken.expirationDate).to( equal(tokenExpirationDate) );
    });

    it(@"gives production URLs by default", ^{
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://api.artsy.net/api/hi") );
    });

    it(@"gives staging URLs when staging is YES", ^{
        sut.staging = YES;
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://stagingapi.artsy.net/api/hi") );
    });

    it(@"gives GET requests by default", ^{
        NSURL *testURL = [NSURL URLWithString:@"http://artsy.net"];
        expect([sut baseRequestForAddress:testURL].HTTPMethod).to( equal(@"GET") );
    });

    it(@"gives other requests by default", ^{
        NSURL *testURL = [NSURL URLWithString:@"http://artsy.net"];
        expect([sut baseRequestForAddress:testURL method:@"POST"].HTTPMethod).to( equal(@"POST") );
    });

    it(@"adds XApp token if it is present", ^{
        NSURL *testURL = [NSURL URLWithString:@"http://artsy.net"];
        NSURLRequest *generatedRequest = [sut baseRequestForAddress:testURL];

        expect(generatedRequest.allHTTPHeaderFields[@"X-Xapp-Token"]).to( equal(xappToken) );
    });

    it(@"XApp requests contain clientID/clientSecret", ^{
        NSURL *xappRequestURL = [sut requestForXapp].URL;
        NSDictionary *parameters = xappRequestURL.uq_queryDictionary;

        expect(parameters[@"client_id"]).to( equal(clientID) );
        expect(parameters[@"client_secret"]).to( equal(clientSecret) );
    });

    it(@"generates Twitter OAuth requests", ^{
        NSString *twitterToken = @"costolo";
        NSString *twitterSecret = @"i_miss_ev";

        NSURLRequest *twitterRequest = [sut newTwitterOAuthRequestWithToken:twitterToken andSecret:twitterSecret];
        NSDictionary *parameters = twitterRequest.URL.uq_queryDictionary;

        expect(twitterRequest.URL.path).to( equal(@"/oauth2/access_token") );
        expect(parameters[@"oauth_token"]).to( equal(twitterToken) );
        expect(parameters[@"oauth_token_secret"]).to( equal(twitterSecret) );
        expect(parameters[@"oauth_provider"]).to( equal(@"twitter") );
        expect(parameters[@"grant_type"]).to( equal(@"oauth_token") );
        expect(parameters[@"scope"]).to( equal(@"offline_access") );

    });

    it(@"generates Facebook OAuth requests", ^{
        NSString *facebookToken = @"token";

        NSURLRequest *facebookRequest = [sut newFacebookOAuthRequestWithToken:facebookToken];
        NSDictionary *parameters = facebookRequest.URL.uq_queryDictionary;

        expect(facebookRequest.URL.path).to( equal(@"/oauth2/access_token") );
        expect(parameters[@"oauth_token"]).to( equal(facebookToken) );
        expect(parameters[@"oauth_provider"]).to( equal(@"facebook") );
        expect(parameters[@"scope"]).to( equal(@"offline_access") );
    });

    it(@"creates users with Facebook tokens", ^{
        NSString *name = @"Mark Zuckerberg";
        NSString *email = @"zuck@facebook.com";
        NSString *facebookToken = @"god_mode";

        NSURLRequest *facebookNewUserRequest = [sut newCreateUserViaFacebookRequestWithToken:facebookToken email:email name:name];
        NSDictionary *parameters = facebookNewUserRequest.URL.uq_queryDictionary;

        expect(facebookNewUserRequest.URL.path).to( equal(@"/api/v1/user") );
        expect(parameters[@"email"]).to( equal(email) );
        expect(parameters[@"name"]).to( equal(name) );
        expect(parameters[@"oauth_token"]).to( equal(facebookToken) );
        expect(parameters[@"provider"]).to( equal(@"facebook") );
        expect(parameters[@"client_id"]).to( beNil() );
        expect(parameters[@"client_secret"]).to( beNil() );
    });

    it(@"logs in with email", ^{
        NSString *email = @"2cool4school@thedumptersbehindtheschool.com";
        NSString *password = @"glitter";
        NSURLRequest *loginRequest = [sut requestForAuthWithEmail:email password:password];
        NSDictionary *parameters = loginRequest.URL.uq_queryDictionary;

        expect(loginRequest.URL.path).to( equal(@"/oauth2/access_token") );
        expect(parameters[@"email"]).to( equal(email) );
        expect(parameters[@"password"]).to( equal(password) );
        expect(parameters[@"grant_type"]).to( equal(@"credentials") );
        expect(parameters[@"scope"]).to( equal(@"offline_access") );
    });
});

QuickSpecEnd
