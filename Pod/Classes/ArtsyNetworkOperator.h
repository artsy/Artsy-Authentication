#import <Foundation/Foundation.h>

typedef void (^ArtsyNetworkSuccessCallback)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^ArtsyNetworkFailureCallback)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);

@interface ArtsyNetworkOperator : NSObject

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request
                                  success:(ArtsyNetworkSuccessCallback)success
                                  failure:(ArtsyNetworkFailureCallback)failure;

@end
