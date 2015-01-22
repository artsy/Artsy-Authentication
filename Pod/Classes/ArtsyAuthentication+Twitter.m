#import "ArtsyAuthentication+Twitter.h"
#import "ArtsyAuthentication+Private.h"
#import "ArtsyAuthenticationRouter.h"
#import "ArtsyNetworkOperator.h"
#import "ArtsyToken.h"
@import TwitterReverseAuth;
@import ISO8601DateFormatter;
#import <objc/runtime.h>

typedef void (^_ArtsyTwitterAuthenticationCallback)(NSString *oauthToken, NSString *oauthSecret, NSString *twitterUsername, NSError *error);

const void* ArtsyTwitterReverseAuthKey = &ArtsyTwitterReverseAuthKey;
const void* ArtsyTwitterAPIKeyKey = &ArtsyTwitterAPIKeyKey;
const void* ArtsyTwitterAPISecretKey = &ArtsyTwitterAPISecretKey;

@interface ArtsyAuthentication(Twitter_Private) <TRATwitterReverseAuthDelegate>

@property (nonatomic, readonly) TRATwitterReverseAuth *reverseAuth;

@end

@implementation ArtsyAuthentication(Twitter_Private)

#pragma mark - Private Properties

- (TRATwitterReverseAuth *)reverseAuth {
    TRATwitterReverseAuth *reverseAuth = objc_getAssociatedObject(self, ArtsyTwitterReverseAuthKey);

    if (!reverseAuth) {
        reverseAuth = [[TRATwitterReverseAuth alloc] initWithDelegate:self];

        objc_setAssociatedObject(self, ArtsyTwitterReverseAuthKey, reverseAuth, OBJC_ASSOCIATION_RETAIN);
    }

    return reverseAuth;
}

#pragma mark - TRATwitterReverseAuthDelegate Methods

- (NSString *)APIKeyForTwitterReverseAuth:(TRATwitterReverseAuth *)reverseAuth {
    return self.twitterAPIKey;
}

- (NSString *)APISecretForTwitterReverseAuth:(TRATwitterReverseAuth *)reverseAuth {
    return self.twitterAPISecret;
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

- (void)logInWithTwitterAccount:(ACAccount *)accout completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [self checkForKeys];

    [self.reverseAuth requestCredentialsForAccount:accout completion:^(NSDictionary *credentials, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (credentials.count > 0) {
            [strongSelf logInWithTwitterAccount:accout credentials:credentials completion:callback];
        } else {
            [strongSelf callback:nil error:error completion:callback];
        }
    }];
}

- (void)createNewUserWithTwitter:(ACAccount *)accout email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [self checkForKeys];

    [self.reverseAuth requestCredentialsForAccount:accout completion:^(NSDictionary *credentials, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (credentials.count > 0) {
            [strongSelf createUserWithTwitterAccount:accout email:email name:name credentials:credentials completion:callback];
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
