@import Quick;
@import Nimble;
@import Artsy_Authentication;

QuickSpecBegin(ArtsyTokenTests)

describe(@"a token", ^{
    it(@"successfully initializes", ^{
        NSString *xappToken = @"is_it_exapp_or_zapp";
        NSDate *tokenExpirationDate = [NSDate distantFuture];
        ArtsyToken *sut = [[ArtsyToken alloc] initWithToken:xappToken expirationDate:tokenExpirationDate];

        expect(sut.token).to( equal(xappToken) );
        expect(sut.expirationDate).to( equal(tokenExpirationDate) );
    });

    it(@"returns empty correctly", ^{
        ArtsyToken *sut = [[ArtsyToken alloc] initWithToken:@"non_empty_string" expirationDate:[NSDate date]];
        expect(@(sut.empty)).to( equal(@(NO)) );

        sut = [[ArtsyToken alloc] initWithToken:@"" expirationDate:[NSDate date]];
        expect(@(sut.empty)).to( equal(@(YES)) );
    });

    it(@"returns hasExpired correctly.", ^{
        ArtsyToken *sut = [[ArtsyToken alloc] initWithToken:@"" expirationDate:[NSDate distantFuture]];
        expect(@(sut.hasExpired)).to( equal(@(NO)) );

        sut = [[ArtsyToken alloc] initWithToken:@"" expirationDate:[NSDate distantPast]];
        expect(@(sut.hasExpired)).to( equal(@(YES)) );
    });

    it(@"returns hasExpiredWithDate: correctly.", ^{
        ArtsyToken *sut = [[ArtsyToken alloc] initWithToken:@"" expirationDate:[NSDate distantFuture]];
        expect(@([sut hasExpiredWithDate:[NSDate date]])).to( equal(@(NO)) );

        sut = [[ArtsyToken alloc] initWithToken:@"" expirationDate:[NSDate distantPast]];
        expect(@([sut hasExpiredWithDate:[NSDate date]])).to( equal(@(YES)) );
    });
});

QuickSpecEnd
