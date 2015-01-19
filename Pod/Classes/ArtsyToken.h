#import <Foundation/Foundation.h>

/// Represents a token + expiration combination

@interface ArtsyToken : NSObject <NSSecureCoding, NSCopying>

- (instancetype)initWithToken:(NSString *)token expirationDate:(NSDate *)expirationDate NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSDate *expirationDate;
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

- (BOOL)hasExpired;
- (BOOL)hasExpiredWithDate:(NSDate *)date;

@end
