#import "ARViewController.h"

#import <Pods_Artsy_Authentication/Artsy_AuthenticationKeys.h>

@import Artsy_Authentication;

@interface ARViewController ()

@property (nonatomic, strong) ArtsyAuthentication *auth;
@property (nonatomic, strong) Artsy_AuthenticationKeys *keys;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.keys = [Artsy_AuthenticationKeys new];

    ArtsyAuthentication *auth = [[ArtsyAuthentication alloc] initWithClientID:self.keys.artsyAPIClientKey clientSecret:self.keys.artsyAPIClientSecret];
    auth.twitterAPIKey = self.keys.artsyFacebookTwitterKey;
    auth.twitterAPISecret = self.keys.artsyFacebookTwitterSecret;
    self.auth = auth;

//    [self doTwitter];
}

- (void)doTwitter {
    ArtsyAuthentication *auth = self.auth;

    NSLog(@"Getting Xapp token.");
    [auth getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {
        NSLog(@"Retrieved Xapp token: %@", token);

        NSLog(@"Retrieving Twitter accounts.");
        [auth retrieveTwitterAccounts:^(NSArray *accounts, NSError *error) {
            ACAccount *account = accounts.firstObject;
            NSLog(@"Retrieved %@ Twitter accounts. Choosing the first (%@).", @(accounts.count), account.username);

            NSLog(@"Logging in with Twitter.");
            [auth logInWithTwitterAccount:account completion:^(ArtsyToken *token, NSError *error) {
                if (error) {
                    if ([error.domain isEqualToString:ArtsyAuthenticationErrorDomain] && error.code == ArtsyErrorUserDoesNotExist) {
                        NSLog(@"User does not exist. Creating with Twitter token.");
                        [auth createNewUserWithTwitter:account email:@"ash_example@example.com" name:@"Example Furrow" completion:^(ArtsyToken *token, NSError *error) {
                            if (error) {
                                NSLog(@"Error creating user: %@", error);
                            } else {
                                NSLog(@"Successfully created Artsy user.");
                                NSLog(@"Retrieved ArtsyToken: %@", token);
                            }
                        }];
                    } else {
                        NSLog(@"Error logging in: %@", error);
                    }
                }

                if (token) {
                    NSLog(@"Retrieved ArtsyToken: %@", token);
                }
            }];
        }];
    }];
}

- (void)doFacebook {
    ArtsyAuthentication *auth = self.auth;
    NSString *facebookAppID = self.keys.artsyFacebookAppID;

    NSLog(@"Getting Xapp token.");
    [auth getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {
        NSLog(@"Retrieved Xapp token: %@", token);

        NSLog(@"Logging in with Facebook.");
        [auth logInWithFacebook:facebookAppID completion:^(ArtsyToken *token, NSError *error) {
            if (error) {
                if ([error.domain isEqualToString:ArtsyAuthenticationErrorDomain] && error.code == ArtsyErrorUserDoesNotExist) {
                    NSLog(@"User does not exist. Creating with Facebook token.");
                    [auth createUserWithFacebook:facebookAppID completion:^(ArtsyToken *token, NSError *error) {
                        if (error) {
                            NSLog(@"Error creating user: %@", error);
                        } else {
                            NSLog(@"Successfully created Artsy user.");
                            NSLog(@"Retrieved ArtsyToken: %@", token);
                        }
                    }];
                } else {
                    NSLog(@"Error logging in: %@", error);
                }
            }

            if (token) {
                NSLog(@"Retrieved ArtsyToken: %@", token);
            }
        }];
    }];
}

@end
