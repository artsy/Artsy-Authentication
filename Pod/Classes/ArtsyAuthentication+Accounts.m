#import "ArtsyAuthentication+Accounts.h"
#import "ArtsyAuthentication+Private.h"
#import <objc/runtime.h>

@implementation ArtsyAuthentication (Private)

- (ACAccountStore *)accountStore {
    ACAccountStore *accountStore = objc_getAssociatedObject(self, ArtsyAccountStoreKey);
    
    if (!accountStore) {
        // This must be around at least as long as we are.
        accountStore = [[ACAccountStore alloc] init];
        
        objc_setAssociatedObject(self, ArtsyAccountStoreKey, accountStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return accountStore;
}

@end
