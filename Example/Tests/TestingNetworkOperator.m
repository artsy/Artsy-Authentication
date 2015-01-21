#import "TestingNetworkOperator.h"

@implementation TestingNetworkOperator

- (instancetype)initWithResponse:(NSHTTPURLResponse *)response JSON:(id)JSON error:(NSError *)error {
    self = [super init];
    if (self == nil) { return nil; }

    _response = response;
    _JSON = JSON;
    _error = error;

    return self;
}

- (BOOL)fail {
    return self.error != nil;
}

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure {

    if (self.fail) {
        if (failure) {
            failure(request, self.response, self.error, self.JSON);
        }
    } else {
        if (success) {
            success(request, self.response, self.JSON);
        }
    }

    return nil;
}

@end
