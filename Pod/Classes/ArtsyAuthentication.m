#import "ArtsyAuthentication.h"
#import "ArtsyAuthentication+Private.h"
#import "ArtsyToken.h"
#import "ArtsyAuthenticationRouter.h"

@import ISO8601DateFormatter;

NSString* const ArtsyOAuthTokenKey = @"access_token";
NSString* const ArtsyOAuthExpiryKey = @"expires_in";

NSString* const ArtsyAuthenticationErrorDomain = @"ArtsyAuthenticationErrorDomain";

@interface ArtsyAuthentication()
@end

@implementation ArtsyAuthentication

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;
{
    self = [super init];
    if (!self) return nil;

    _router = [[ArtsyAuthenticationRouter alloc] initWithClientID:clientID clientSecret:clientSecret];

    return self;
}

#pragma mark - Public API

- (void)getWeekLongXAppTrialToken:(void (^)(ArtsyToken *token, NSError *error))completion
{
    __weak __typeof(self) weakSelf = self;

    NSURLRequest *request = [self.router requestForXapp];
    [self getRequest:request:^(id dict, NSURLResponse *response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [self findErrorsInResponse:(NSHTTPURLResponse *)response error:&error dict:dict];

        NSDate *date = [[[ISO8601DateFormatter alloc] init] dateFromString:dict[@"expires_in"]];
        ArtsyToken *token = [[ArtsyToken alloc] initWithToken:dict[@"xapp_token"] expirationDate:date];

        strongSelf.router.xappToken = token;

        completion(token, error);
    }];
}

- (void)getUserApplicationXAccessTokenWithEmail:(NSString *)email password:(NSString *)password :(ArtsyAuthenticationCallback)completion
{
    __weak __typeof(self) weakSelf = self;

    NSURLRequest *request = [self.router requestForAuthWithEmail:email password:password];
    [self getRequest:request:^(id dict, NSURLResponse *response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [self findErrorsInResponse:(NSHTTPURLResponse *)response error:&error dict:dict];

        NSDate *date = [[[ISO8601DateFormatter alloc] init] dateFromString:dict[@"expires_in"]];
        ArtsyToken *token = [[ArtsyToken alloc] initWithToken:dict[@"access_token"] expirationDate:date];

        strongSelf.router.authToken = token;

        [self callback:token error:error completion:completion];
    }];
}

- (void)createUserWithUserDictionary:(NSDictionary *)dictionary :(void (^)(NSDictionary *newUserDictionary, NSError *error))completion
{
    NSURLRequest *request = [self.router requestForXapp];
    [self getRequest:request:^(id dict, NSURLResponse *response, NSError *error) {
        [self findErrorsInResponse:(NSHTTPURLResponse *)response error:&error dict:dict];
        completion(dict, error);
    }];
}

#pragma mark - Request Management

- (void)findErrorsInResponse:(NSHTTPURLResponse *)response error:(NSError **)error dict:(NSDictionary *)dict
{
    if (*error) return;
    if (response.statusCode != 500) {
        *error = [NSError errorWithDomain:@"net.artsy" code:response.statusCode userInfo:dict];
    }
}

- (void)getRequest:(NSURLRequest *)request :(void (^)(id object, NSURLResponse *response, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        id mapped = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        completionHandler(mapped, response, error ?: jsonError);
    }];

    [task resume];
}

- (void)logout {
    self.router.authToken = nil;
}

@end
