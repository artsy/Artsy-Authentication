@import Quick;
@import Nimble;
@import Artsy_Authentication;
@import OHHTTPStubs;

QuickSpecBegin(ArtsyNetworkOperatorTests)

describe(@"a network operator", ^{
    NSURL *url = [NSURL URLWithString:@"https://api.artsy.net/api/hi"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    it(@"calls through to the network to return JSON", ^{
        ArtsyNetworkOperator *sut = [[ArtsyNetworkOperator alloc] init];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL isEqual:url];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"key": @"value"}options:0 error:nil];
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{ @"Content-Type": @"application/json" }];
        }];

        __block BOOL called = NO;
        [sut JSONTaskWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            expect(JSON[@"key"]).to( equal(@"value") );
            called = YES;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            XCTFail(@"Stubbed request failed. Should never happen.");
        }];

        expect(@(called)).toEventually( beTruthy() );
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

QuickSpecEnd
