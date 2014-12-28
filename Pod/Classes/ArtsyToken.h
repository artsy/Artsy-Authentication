#import <Foundation/Foundation.h>

/// Represents a token + expiration combination

@interface ArtsyToken : NSObject <NSSecureCoding>

- (instancetype)initWithToken:(NSString *)token expirationDate:(NSDate *)expirationDate NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSDate *expirationDate;

- (BOOL)hasExpired;
- (BOOL)hasExpiredWithDate:(NSDate *)date;

@end
