#import "ArtsyAuthenticationRouter.h"
#import "ArtsyToken.h"

@import NSURL_QueryDictionary;

@interface ArtsyAuthenticationRouter()

@end

@implementation ArtsyAuthenticationRouter

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    self = [super init];
    if (!self) return nil;

    _clientID = clientID;
    _clientSecret = clientSecret;

    return self;
}

#pragma mark - NSURLRequests for calls

- (NSURL *)urlWithPath:(NSString *)path {
    NSString *base = self.staging ? @"https://stagingapi.artsy.net" : @"https://api.artsy.net";
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:base]];
}

- (NSURLRequest *)baseRequestForAddress:(NSURL *)url method:(NSString *)httpMethod {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = httpMethod;

    if (self.xappToken) {
        [request setValue:self.xappToken.token forHTTPHeaderField:@"X-Xapp-Token"];
    }
    
    return [request copy];
}

- (NSURLRequest *)baseRequestForAddress:(NSURL *)url {
    return [self baseRequestForAddress:url method:@"GET"];
}

- (NSURLRequest *)requestForAuthWithEmail:(NSString *)email password:(NSString *)password {
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

- (NSURLRequest *)requestForCreateNewUserwithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password {
    NSDictionary *params = @{
        @"email" : email,
        @"password" : password,
        @"name" : name
    };

    NSURL *url = [[self urlWithPath:@"/api/v1/user"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url method:@"POST"];
}

- (NSURLRequest *)newCreateUserViaFacebookRequestWithToken:(NSString *)facebookToken email:(NSString *)email name:(NSString *)name {
    NSDictionary *params = @{
        @"provider": @"facebook",
        @"oauth_token": facebookToken,
        @"email" : email,
        @"name" : name
    };

    NSURL *url = [[self urlWithPath:@"/api/v1/user"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url method:@"POST"];
}


- (NSURLRequest *)newFacebookOAuthRequestWithToken:(NSString *)facebookToken {
    NSDictionary *params = @{
        @"oauth_provider" : @"facebook",
        @"oauth_token" : facebookToken,
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"grant_type" : @"oauth_token",
        @"scope" : @"offline_access"
    };

    NSURL *url = [[self urlWithPath:@"/oauth2/access_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

- (NSURLRequest *)newTwitterOAuthRequestWithToken:(NSString *)token secret:(NSString *)secret {
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

- (NSURLRequest *)newCreateUserViaTwitterRequestWithToken:(NSString *)token secret:(NSString *)secret email:(NSString *)email name:(NSString *)name {
    NSDictionary *params = @{
         @"provider": @"twitter",
         @"oauth_token": token,
         @"oauth_token_secret": secret,
         @"email" : email,
         @"name" : name
    };

    NSURL *url = [[self urlWithPath:@"/api/v1/user"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url method:@"POST"];
}

- (NSURLRequest *)requestForXapp {
    NSDictionary *params = @{
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret
    };

    NSURL *url = [[self urlWithPath:@"/api/v1/xapp_token"] uq_URLByAppendingQueryDictionary:params];
    return [self baseRequestForAddress:url];
}

@end
