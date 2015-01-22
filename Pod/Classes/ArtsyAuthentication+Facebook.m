#import "ArtsyAuthentication+Facebook.h"
#import "ArtsyAuthentication+Private.h"
#import "ArtsyAuthenticationRouter.h"
#import "ArtsyNetworkOperator.h"
#import "ArtsyToken.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

typedef void (^_ArtsyFacebookAuthenticationCallback)(NSString *facebookToken, NSString *email, NSString *name, NSError *error);

NSString *facebookAppID() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
}

@interface ArtsyAuthentication (Facebook_Private)
@end

@implementation ArtsyAuthentication (Facebook_Private)

- (SLRequest *)requestForMe:(ACAccount *)facebookAccount {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:nil];
    request.account = facebookAccount;

    return request;
}

- (void)retrieveFacebookAccountInformation:(ACAccount *)facebookAccount completion:(_ArtsyFacebookAuthenticationCallback)callback {
    SLRequest *request = [self requestForMe:facebookAccount];

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData == nil || error || urlResponse.statusCode != 200) {
            if (callback) {
                callback(nil, nil, nil, error);
            }
        } else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

            NSString *facebookToken = facebookAccount.credential.oauthToken;
            NSString *email = responseDictionary[@"email"];
            NSString *name = responseDictionary[@"name"];

            if (callback) {
                callback(facebookToken, email, name, nil);
            }
        }
    }];
}

- (void)loginToArtsyWithFacebookToken:(NSString *)facebookToken completion:(ArtsyAuthenticationCallback)callback {
    NSURLRequest *request = [self.router newFacebookOAuthRequestWithToken:facebookToken];

    [self.networkOperator JSONTaskWithRequest:request success:[self successfulLoginBlock:callback] failure:[self failedLoginBlock:callback]];
}

- (void)createArtsyUserWithFacebookToken:(NSString *)facebookToken email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    NSURLRequest *request = [self.router newCreateUserViaFacebookRequestWithToken:facebookToken email:email name:name];

    [self.networkOperator JSONTaskWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf loginToArtsyWithFacebookToken:facebookToken completion:callback];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf callback:nil error:error completion:callback];
    }];
}

- (void)accessFacebookAccount:(NSString *)appID completion:(_ArtsyFacebookAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    NSArray *permissions = @[@"email"];
    NSDictionary *facebookOptions = @{ACFacebookAppIdKey : appID,
                                      ACFacebookPermissionsKey : permissions};


    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    [self.accountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
            ACAccount *facebookAccount = accounts.lastObject;

            [strongSelf retrieveFacebookAccountInformation:facebookAccount completion:callback];
        } else {
            if (callback) {
                callback(nil, nil, nil, error);
            }
        }
    }];
}

@end

@implementation ArtsyAuthentication (Facebook)

- (void)logInWithFacebook:(ArtsyAuthenticationCallback)callback {
    NSString *appID = facebookAppID();

    if (appID) {
        [self logInWithFacebook:appID completion:callback];
    } else {
        NSError *error = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:ArtsyErrorNoFacebookAppID userInfo:nil];

        [self callback:nil error:error completion:callback];
    }
}

- (void)logInWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    [self accessFacebookAccount:appID completion:^(NSString *facebookToken, NSString *email, NSString *name, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (facebookToken && name && email && !error) {
            [strongSelf loginToArtsyWithFacebookToken:facebookToken completion:callback];
        } else {
            callback(nil, error);
        }
    }];
}

- (void)createUserWithFacebook:(ArtsyAuthenticationCallback)callback {
    NSString *appID = facebookAppID();

    if (appID) {
        [self createUserWithFacebook:appID completion:callback];
    } else {
        NSError *error = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:ArtsyErrorNoFacebookAppID userInfo:nil];

        [self callback:nil error:error completion:callback];
    }
}

- (void)createUserWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    [self accessFacebookAccount:appID completion:^(NSString *facebookToken, NSString *email, NSString *name, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (facebookToken && name && email && !error) {
            [strongSelf createArtsyUserWithFacebookToken:facebookToken email:email name:name completion:callback];
        } else {
            callback(nil, error);
        }
    }];
}

@end
