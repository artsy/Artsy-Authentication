#import "ArtsyAuthentication+Twitter.h"
#import "ArtsyAuthentication+Private.h"
#import "ArtsyAuthenticationRouter.h"
#import "ArtsyNetworkOperator.h"
#import "ArtsyToken.h"
#import <LVTwitterOAuthClient/LVTwitterOAuthClient.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <objc/runtime.h>

typedef void (^_ArtsyTwitterAuthenticationCallback)(NSString *oauthToken, NSString *oauthSecret, NSString *twitterUsername, NSError *error);

const void* ArtsyTwitterReverseAuthKey = &ArtsyTwitterReverseAuthKey;
const void* ArtsyTwitterAPIKeyKey = &ArtsyTwitterAPIKeyKey;
const void* ArtsyTwitterAPISecretKey = &ArtsyTwitterAPISecretKey;

@interface ArtsyAuthentication(Twitter_Private)

@property (nonatomic, readonly) LVTwitterOAuthClient *reverseAuth;

@end

@implementation ArtsyAuthentication(Twitter_Private)

#pragma mark - Private Properties

- (LVTwitterOAuthClient *)reverseAuth {
    LVTwitterOAuthClient *reverseAuth = objc_getAssociatedObject(self, ArtsyTwitterReverseAuthKey);

    if (!reverseAuth) {
        reverseAuth = [[LVTwitterOAuthClient alloc] initWithConsumerKey:self.twitterAPIKey andConsumerSecret:self.twitterAPISecret];

        objc_setAssociatedObject(self, ArtsyTwitterReverseAuthKey, reverseAuth, OBJC_ASSOCIATION_RETAIN);
    }

    return reverseAuth;
}

#pragma mark - Private

- (void)checkForKeys {
    NSAssert(self.twitterAPIKey != nil, @"No Twitter API Key.");
    NSAssert(self.twitterAPISecret != nil, @"No Twitter API secret.");
}

- (void)createUserWithTwitterAccount:(ACAccount *)accout email:(NSString *)email name:(NSString *)name credentials:(NSDictionary *)credentials completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    NSString *oauthToken = credentials[@"oauth_token"];
    NSString *oauthSecret = credentials[@"oauth_token_secret"];

    NSURLRequest *request = [self.router newCreateUserViaTwitterRequestWithToken:oauthToken secret:oauthSecret email:email name:name];

    [self.networkOperator JSONTaskWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf logInWithTwitterAccount:accout completion:callback];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf callback:nil error:error completion:callback];
    }];
}

- (void)logInWithTwitterAccount:(ACAccount *)accout credentials:(NSDictionary *)credentials completion:(ArtsyAuthenticationCallback)callback {
    NSString *oauthToken = credentials[@"oauth_token"];
    NSString *oauthSecret = credentials[@"oauth_token_secret"];

    NSURLRequest *request = [self.router newTwitterOAuthRequestWithToken:oauthToken secret:oauthSecret];

    [self.networkOperator JSONTaskWithRequest:request success:[self successfulLoginBlock:callback] failure:[self failedLoginBlock:callback]];
}

@end

@implementation ArtsyAuthentication(Twitter)

#pragma mark - Public API

- (void)retrieveTwitterAccounts:(ArtsyTwitterAccountsCallback)callback {
    [self checkForKeys];
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [self.accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
            if (callback) {
                callback(accounts, error);
            }
        } else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (void)logInWithTwitterAccount:(ACAccount *)account completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [self checkForKeys];
    [self.reverseAuth requestTokensForAccount:account completionBlock:^(NSDictionary *oAuthResponse, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (oAuthResponse[kLVOAuthAccessTokenKey] && !error) {
            [strongSelf logInWithTwitterAccount:account credentials:oAuthResponse completion:callback];
        } else {
            [strongSelf callback:nil error:error completion:callback];
        }
    }];
}

- (void)createNewUserWithTwitter:(ACAccount *)account email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [self checkForKeys];
    [self.reverseAuth requestTokensForAccount:account completionBlock:^(NSDictionary *oAuthResponse, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (oAuthResponse[kLVOAuthAccessTokenKey] && !error) {
            [strongSelf createUserWithTwitterAccount:account email:email name:name credentials:oAuthResponse completion:callback];
        } else {
            [strongSelf callback:nil error:error completion:callback];
        }
    }];
}

#pragma mark - Properties

- (NSString *)twitterAPIKey {
    return objc_getAssociatedObject(self, ArtsyTwitterAPIKeyKey);
}

- (void)setTwitterAPIKey:(NSString *)twitterAPIKey {
    objc_setAssociatedObject(self, ArtsyTwitterAPIKeyKey, twitterAPIKey, OBJC_ASSOCIATION_COPY);
}

- (NSString *)twitterAPISecret {
    return objc_getAssociatedObject(self, ArtsyTwitterAPISecretKey);
}

- (void)setTwitterAPISecret:(NSString *)twitterAPISecret {
    objc_setAssociatedObject(self, ArtsyTwitterAPISecretKey, twitterAPISecret, OBJC_ASSOCIATION_COPY);
}

@end
