//
//  UberAPIAccessToken.h
//  UberOAuth2
//
//  Created by Oleg Shanyuk on 10.07.17.
//  Copyright © 2017 coderyi. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface UberAPIAccessToken : NSObject<NSCoding, NSCopying>

@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *refreshToken;
@property (nonatomic, readonly) NSDate *expirationDate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate *)expiration;

- (BOOL)isExpired;
- (BOOL)isNotEmpty;

@end

NS_ASSUME_NONNULL_END
