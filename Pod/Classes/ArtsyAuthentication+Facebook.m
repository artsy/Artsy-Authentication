#import "ArtsyAuthentication+Facebook.h"
#import "ArtsyAuthentication+Private.h"
#import <AFNetworking/AFNetworking.h>
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
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:nil error:nil];

            NSString *facebookToken = facebookAccount.credential.oauthToken;
            NSString *email = responseDictionary[@"email"];
            NSString *name = responseDictionary[@"name"];

            [strongSelf loginToArtsyWithFacebookToken:facebookToken email:email name:name completion:callback];
        }
    }];
}

- (void)loginToArtsyWithFacebookToken:(NSString *)token email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback {
    // TODO: This method. 🚢
}

@end

@implementation ArtsyAuthentication (Facebook)

- (void)logInWithFacebook:(NSString *)appID completion:(ArtsyAuthenticationCallback)callback {
    __weak __typeof(self) weakSelf = self;

    NSArray *permissions = @[@"email"];
    NSDictionary *facebookOptions = @{ACFacebookAppIdKey : appID,
                                      ACFacebookAudienceKey :  ACFacebookAudienceFriends,
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
