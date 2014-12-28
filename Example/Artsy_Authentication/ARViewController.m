#import "ARViewController.h"
@import Artsy_Authentication;

@interface ARViewController ()
@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ArtsyAuthentication *auth = [[ArtsyAuthentication alloc] initWithClientID:@"" clientSecret:@""];
    [auth getWeekLongXAppTrialToken:^(ArtsyToken *token, NSError *error) {

    }];
}

@end
