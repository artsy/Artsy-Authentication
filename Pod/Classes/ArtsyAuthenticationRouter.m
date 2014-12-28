#import "ArtsyAuthenticationRouter.h"
#import "ArtsyToken.h"

@import NSURL_QueryDictionary;

@interface ArtsyAuthenticationRouter()
@property (readonly, nonatomic, copy) NSString *clientID;
@property (readonly, nonatomic, copy) NSString *clientSecret;

@property (readonly, nonatomic, copy) ArtsyToken *xappToken;
@property (readonly, nonatomic, copy) ArtsyToken *authToken;
@end

@implementation ArtsyAuthenticationRouter

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;
{
    self = [super init];
    if (!self) return nil;

    _clientID = clientID;
    _clientSecret = clientSecret;

    return self;
}

#pragma mark - NSURLRequests for calls

- (NSURL *)urlWithPath:(NSString *)path
{
    NSString *base = self.staging ? @"https://api-staging.artsy.net" : @"https://api.artsy.net";
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:base]];
}

- (NSURLRequest *)baseRequestForAddress:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (self.xappToken) {
        [request setValue:@"X-Xapp-Token" forHTTPHeaderField:self.xappToken.token];
    }
    return [request copy];
}

- (NSURLRequest *)requestForAuthWithEmail:(NSString *)email password:(NSString *)password
{
    NSDictionary *params = @{
        @"email" : email,
        @"password" : password,
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"grant_type" : @"credentials",
        @"scope" : @"offline_access"
    };

    NSURL *url = [[self urlWithPath:@"/oauth2/access_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

- (NSURLRequest *)newFacebookOAuthRequestWithToken:(NSString *)token
{
    NSDictionary *params = @{
        @"oauth_provider" : @"facebook",
        @"oauth_token" : token,
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"grant_type" : @"oauth_token",
        @"scope" : @"offline_access"
    };

    NSURL *url = [[self urlWithPath:@"/oauth2/access_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

- (NSURLRequest *)newTwitterOAuthRequestWithToken:(NSString *)token andSecret:(NSString *)secret
{
    NSDictionary *params = @{
        @"oauth_provider" : @"twitter",
        @"oauth_token" : token,
        @"oauth_token_secret" : secret,
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"grant_type" : @"oauth_token",
        @"scope" : @"offline_access"
    };

    NSURL *url = [[self urlWithPath:@"/oauth2/access_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

- (NSURLRequest *)requestForXapp
{
    NSDictionary *params = @{
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret
    };

    NSURL *url = [[self urlWithPath:@"/api/v1/xapp_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

@end
