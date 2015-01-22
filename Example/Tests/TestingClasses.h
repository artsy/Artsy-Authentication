@import Foundation;
@import Artsy_Authentication;
@import Social;
@import TwitterReverseAuth;
#import "TestingNetworkOperator.h"

extern const void* ArtsyAccountStoreKey;
extern const void* ArtsyTwitterReverseAuthKey;

@interface ArtsyAuthentication(Test)

- (SLRequest *)requestForMe:(ACAccount *)facebookAccount;

@property (nonatomic, strong) ArtsyNetworkOperator *networkOperator;

@end


@interface StubbedAuthenticator : ArtsyAuthentication
@end

@interface FacebookTestingAccountStore : ACAccountStore
@end

@interface TwitterTestingAccountStore : ACAccountStore
@end

@interface TestingResponse : NSHTTPURLResponse
@property (readwrite) NSInteger statusCode;
@end

@interface FacebookTestingAccount : ACAccount
@end

@interface TwitterTestingAccount : ACAccount
@end

@interface TestingTwitterReverseAuth : TRATwitterReverseAuth

@end
