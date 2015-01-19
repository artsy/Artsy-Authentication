#import "ArtsyAuthentication+Facebook.h"
#import "ArtsyAuthentication+Private.h"
#import "ArtsyAuthenticationRouter.h"
#import "ArtsyToken.h"
#import <AFNetworking/AFNetworking.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <objc/runtime.h>

const void* ArtsyFacebookAccountStoreKey = &ArtsyFacebookAccountStoreKey;

@interface ArtsyAuthentication (Facebook_Private)

@property (nonatomic, readonly) ACAccountStore *facebookAccountStore;

@end

@implementation ArtsyAuthentication (Facebook_Private)

- (ACAccountStore *)facebookAccountStore {
    ACAccountStore *accountStore = objc_getAssociatedObject(self, ArtsyFacebookAccountStoreKey);

    if (!accountStore) {
        // This must be around at least as long as we are.
        accountStore = [[ACAccountStore alloc] init];

        objc_setAssociatedObject(self, ArtsyFacebookAccountStoreKey, accountStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return accountStore;
}

- (void)retrieveFacebookAccountInformation:(ACAccount *)facebookAccount completion:(ArtsyAuthenticationCallback)callback {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:nil];
    request.account = facebookAccount;

    __weak __typeof(self) weakSelf = self;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (responseData == nil || error || urlResponse.statusCode != 200) {
            [strongSelf callback:nil error:error completion:callback];
        } else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

            NSString *facebookToken = facebookAccount.credential.oauthToken;
            NSString *email = responseDictionary[@"email"];
            NSString *name = responseDictionary[@"name"];

            [strongSelf loginToArtsyWithFacebookToken:facebookToken email:email name:name completion:callback];
        }
    }];
}

- (void)loginToArtsyWithFacebookToken:(NSString *)facebookToken email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {
   NSURLRequest *request = [self.router newFacebookOAuthRequestWithToken:facebookToken];

    __weak __typeof(self) weakSelf = self;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *oauthRequest, NSHTTPURLResponse *response, id JSON) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            NSString *token = JSON[ArtsyOAuthTokenKey];
            NSString *expiryDateString = JSON[ArtsyOAuthExpiryKey];
            ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
            NSDate *expiryDate = [dateFormatter dateFromString:expiryDateString];

            ArtsyToken *artsyToken = [[ArtsyToken alloc] initWithToken:token expirationDate:expiryDate];

            [strongSelf callback:artsyToken error:nil completion:callback];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            // This case handles a 401 from Artsy's server, which means the Facebook account is not associated with a user.
            if (response.statusCode == 401) {
                NSError *artsyError = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:ArtsyErrorUserDoesNotExist userInfo:@{ NSUnderlyingErrorKey : error }];

                [strongSelf callback:nil error:artsyError completion:callback];
            } else {
                [strongSelf callback:nil error:error completion:callback];
            }
        }];
    [op start];
}

@end

@implementation ArtsyAuthentication (Facebook)

- (void)logInWithFacebook:(ArtsyAuthenticationCallback)callback {

    NSString *appID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];

    if (appID) {
        [self logInWithFacebook:appID completion:callback];
    } else {
        NSError *error = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:ArtsyErrorNoFacebookAppID userInfo:nil];

        [self callback:nil error:error completion:callback];
    }
}

- (void)logInWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    NSArray *permissions = @[@"email"];
    NSDictionary *facebookOptions = @{ACFacebookAppIdKey : appID,
                                      ACFacebookPermissionsKey : permissions};


    ACAccountType *accountType = [self.facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    [self.facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (granted) {
            NSArray *accounts = [self.facebookAccountStore accountsWithAccountType:accountType];
            ACAccount *facebookAccount = accounts.lastObject;

            [strongSelf retrieveFacebookAccountInformation:facebookAccount completion:callback];
        } else {
            [strongSelf callback:nil error:error completion:callback];
        }
    }];
}

@end
