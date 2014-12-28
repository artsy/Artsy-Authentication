@import Quick;
@import Nimble;
@import Artsy_Authentication;
@import OHHTTPStubs;

@interface ArtsyAuthentication(Tests)
- (NSURL *)urlWithPath:(NSString *)path;
- (NSURLRequest *)baseRequestForAddress:(NSString *)address;
@end

QuickSpecBegin(MainSpec)

describe(@"", ^{
    __block ArtsyAuthentication *sut = nil;

    beforeEach(^{
        sut = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
        expect(sut).to( equal(sut) );
    });
});

describe(@"staging / production", ^{
    it(@"gives production urls by default", ^{
        id sut = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://api.artsy.net/api/hi") );
    });

    it(@"gives staging urls when set", ^{
        ArtsyAuthentication *sut = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
        sut.staging = YES;
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://api-staging.artsy.net/api/hi") );
    });
});

describe(@"staging / production", ^{
    it(@"gives production urls by default", ^{
        id sut = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://api.artsy.net/api/hi") );
    });

    it(@"gives staging urls when set", ^{
        ArtsyAuthentication *sut = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
        sut.staging = YES;
        expect([sut urlWithPath:@"/api/hi"].absoluteString).to( equal(@"https://api-staging.artsy.net/api/hi") );
    });
});


QuickSpecEnd
