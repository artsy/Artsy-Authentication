#import "ARViewController.h"

#import <Pods_Artsy_Authentication/Artsy_AuthenticationKeys.h>

@import Artsy_Authentication;

@interface ARViewController ()

@property (nonatomic, strong) ArtsyAuthentication *auth;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    Artsy_AuthenticationKeys *keys = [Artsy_AuthenticationKeys new];

    ArtsyAuthentication *auth = [[ArtsyAuthentication alloc] initWithClientID:keys.artsyAPIClientKey clientSecret:keys.artsyAPIClientSecret];
    auth.router.staging = YES;
    self.auth = auth;

    NSString *facebookAppID = keys.artsyFacebookAppID;

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
            } else if (token) {
                NSLog(@"Retrieved ArtsyToken: %@", token);
            }
        }];
    }];
}

@end
