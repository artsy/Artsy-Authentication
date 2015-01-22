#import "ArtsyAuthentication.h"
#import <Accounts/Accounts.h>

typedef void (^ArtsyTwitterAccountsCallback)(NSArray *accounts, NSError *error);

@interface ArtsyAuthentication(Twitter)

- (void)retrieveTwitterAccounts:(ArtsyTwitterAccountsCallback)callback;
- (void)logInWithTwitterAccount:(ACAccount *)accout completion:(ArtsyAuthenticationCallback)callback;
- (void)createNewUserWithTwitter:(ACAccount *)accout email:(NSString *)email name:(NSString *)name completion:(ArtsyAuthenticationCallback)callback;

@property (nonatomic, copy) NSString *twitterAPIKey;
@property (nonatomic, copy) NSString *twitterAPISecret;

@end
