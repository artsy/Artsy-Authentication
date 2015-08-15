#import "ARViewController.h"

@import Keys;
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
    auth.twitterAPIKey = self.keys.artsyTwitterKey;
    auth.twitterAPISecret = self.keys.artsyTwitterSecret;
    self.auth = auth;
}

- (IBAction)artsyAuthTapped:(id)sender
{
    [self doArtsy];
}

- (IBAction)twitterAuthTapped:(id)sender
{
    [self doTwitter];
}

- (IBAction)facebookAuthTapped:(id)sender
{
    [self doFacebook];
}

- (void)doArtsy {
    ArtsyAuthentication *auth = self.auth;

    NSLog(@"Getting Xapp token.");
    [auth getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {
        NSLog(@"Retrieved Xapp token: %@", token);

        NSString *email = @"starlord@example.com";
        NSString *name = @"Star Lord";
        NSString *password = @"1234Pasd1";

        [auth logInWithEmail:email password:password completion:^(ArtsyToken *token, NSError *error) {
            NSLog(@"Logged in with token %@", token.token);

        }];
        
        NSLog(@"Creating new user %@", email);
        [auth createUserWithEmail:email name:name password:password completion:^(NSDictionary *newUserDictionary, NSError *error) {
            NSLog(@"Created new user: %@", newUserDictionary);

            [auth logInWithEmail:email password:password completion:^(ArtsyToken *token, NSError *error) {
                if (error) {
                    NSLog(@"Error logging in: %@", error);
                }

                if (token) {
                    NSLog(@"Retrieved ArtsyToken: %@", token);
                }
            }];
        }];
    }];
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
