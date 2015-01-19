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
    self.auth = auth;

    NSLog(@"Getting Xapp token.");
    [auth getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {
        NSLog(@"Logging in with Facebook.");
        [auth logInWithFacebook:keys.artsyFacebookStagingToken completion:^(ArtsyToken *token, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else if (token) {
                NSLog(@"Retrieved ArtsyToken: %@", token);
            }
        }];
    }];
}

@end
