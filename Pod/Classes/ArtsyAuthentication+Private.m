#import "ArtsyAuthentication+Private.h"
#import <objc/runtime.h>

const void* ArtsyAccountStoreKey = &ArtsyAccountStoreKey;

@implementation ArtsyAuthentication (Private)

// Just to silence the compiler warning. 
@dynamic networkOperator;

- (void)callback:(ArtsyToken *)token error:(NSError *)error completion:(ArtsyAuthenticationCallback)callback {
    if (callback) {
        callback(token, error);
    }
}

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
