#import <Accounts/Accounts.h>
#import "ArtsyAuthentication.h"

@interface ArtsyAuthentication (PrivateAccount)
@property (nonatomic, readonly) ACAccountStore *accountStore;
@end
