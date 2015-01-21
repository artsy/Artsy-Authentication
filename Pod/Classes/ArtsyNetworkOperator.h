#import <Foundation/Foundation.h>

@interface ArtsyNetworkOperator : NSObject

- (NSURLSessionTask *)JSONTaskWithRequest:(NSURLRequest *)request
                                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
