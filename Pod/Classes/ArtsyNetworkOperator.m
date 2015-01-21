#import "ArtsyNetworkOperator.h"

@implementation ArtsyNetworkOperator

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request
                                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        id JSON;
        NSError *jsonError;

        if (data) {
            JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        }

        NSInteger statusCode = httpResponse.statusCode;
        BOOL validStatusCode = statusCode >= 200 && statusCode < 300;
        if (validStatusCode && data && JSON && !error) {
            success(request, httpResponse, JSON);
        } else {
            failure(request, httpResponse, error ?: jsonError, JSON);
        }
    }];

    [task resume];
    
    return task;
}

@end
