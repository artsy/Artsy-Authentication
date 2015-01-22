#import "ArtsyNetworkOperator.h"
#import "ArtsyAuthentication.h"

@implementation ArtsyNetworkOperator

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request
                                  success:(ArtsyNetworkSuccessCallback)success
                                  failure:(ArtsyNetworkFailureCallback)failure {
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        id JSON;
        NSError *jsonError;

        if (data) {
            JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        }

        NSInteger statusCode = httpResponse.statusCode;

        NSDictionary *userInfo;
        if (error || jsonError) {
            userInfo = @{ NSUnderlyingErrorKey : error ?: jsonError };
        }
        NSError *networkError = [NSError errorWithDomain:ArtsyAuthenticationErrorDomain code:statusCode userInfo:userInfo];

        BOOL validStatusCode = statusCode >= 200 && statusCode < 300;
        if (validStatusCode && data && JSON && !error) {
            success(request, httpResponse, JSON);
        } else {
            failure(request, httpResponse, networkError, JSON);
        }
    }];

    [task resume];
    
    return task;
}

@end
