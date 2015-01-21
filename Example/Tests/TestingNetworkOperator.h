@import Foundation;
@import Artsy_Authentication;

/// JSONTaskWithRequest:success:failure: calls the appropriate
/// block based on the fail property and *returns nil*.
@interface TestingNetworkOperator : ArtsyNetworkOperator

/// The presence of a non-nil error value indicate a failure.
/// Otherwise a success.
- (instancetype)initWithResponse:(NSHTTPURLResponse *)response JSON:(id)JSON error:(NSError *)error NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) id JSON;
@property (nonatomic, readonly) NSError *error;

/// Computed based on error != nil
@property (nonatomic, readonly) BOOL fail;

@end
