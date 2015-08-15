#import "TestingClasses.h"
@import Accounts;

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

@implementation TwitterTestingAccount

- (ACAccountCredential *)credential {
    return [[ACAccountCredential alloc] initWithOAuthToken:@"twitter_token" tokenSecret:@"twitter_secret"];
}

@end

@implementation FacebookTestingAccount

- (ACAccountCredential *)credential {
    return [[ACAccountCredential alloc] initWithOAuth2Token:@"facebook_token" refreshToken:@"facebook_refresh_token"expiryDate:[NSDate distantFuture]];
}

@end

@implementation FacebookTestingAccountStore

- (void)requestAccessToAccountsWithType:(ACAccountType *)accountType options:(NSDictionary *)options completion:(ACAccountStoreRequestAccessCompletionHandler)completion {
    completion(YES, nil);
}

- (NSArray *)accountsWithAccountType:(ACAccountType *)accountType {
    return @[[FacebookTestingAccount new]];
}

@end

@implementation TwitterTestingAccountStore

- (void)requestAccessToAccountsWithType:(ACAccountType *)accountType options:(NSDictionary *)options completion:(ACAccountStoreRequestAccessCompletionHandler)completion {
    completion(YES, nil);
}

- (NSArray *)accountsWithAccountType:(ACAccountType *)accountType {
    return @[[TwitterTestingAccount new]];
}

@end

@implementation TestingResponse

@synthesize statusCode;

@end

@implementation TestingTwitterReverseAuth


- (void)requestTokensForAccount:(ACAccount *)account completionBlock:(void(^)(NSDictionary *credentials, NSError *error))completion {
    completion(@{ @"oauth_token" : @"twitter_token", @"oauth_token_secret": @"twitter_secret" }, nil);
}

@end
