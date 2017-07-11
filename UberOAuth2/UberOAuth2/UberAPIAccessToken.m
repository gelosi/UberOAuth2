//
//  UberAPIAccessToken.m
//  UberOAuth2
//
//  Created by Oleg Shanyuk on 10.07.17.
//  Copyright © 2017 coderyi. All rights reserved.
//

#import "UberAPIAccessToken.h"

// Use this doc:
// // https://developer.uber.com/docs/riders/guides/authentication/introduction#get-an-access-token
// Struct to parse:
/* {
    "access_token": "xxx",
    "token_type": "Bearer",
    "expires_in": 2592000,
    "refresh_token": "xxx",
    "scope": "profile history"
 } */

@implementation UberAPIAccessToken

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    _accessToken = [aDecoder decodeObjectForKey:@"access_token"];
    _refreshToken = [aDecoder decodeObjectForKey:@"refresh_token"];
    _expirationDate = [aDecoder decodeObjectForKey:@"expiration_date"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_accessToken forKey:@"access_token"];
    [aCoder encodeObject:_refreshToken forKey:@"refresh_token"];
    [aCoder encodeObject:_expirationDate forKey:@"expiration_date"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSNumber *expires_in = dictionary[@"expires_in"];
    NSDate *expirationDate;
    if( expires_in) {
        expirationDate = [NSDate dateWithTimeIntervalSinceNow:expires_in.doubleValue];
    }
    
    return [self initWithAccessToken:dictionary[@"access_token"]
                        refreshToken:dictionary[@"refresh_token"]
                      expirationDate:expirationDate];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expirationDate:(NSDate *)expiration
{
    self = [super init];
    
    if ( self) {
        _accessToken = accessToken.copy;
        _refreshToken = refreshToken.copy;
        _expirationDate = expiration.copy;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [UberAPIAccessToken new];
    
    copy->_accessToken = _accessToken.copy;
    copy->_refreshToken = _refreshToken.copy;
    copy->_expirationDate = _expirationDate.copy;
    
    return copy;
}

- (BOOL)isExpired
{
    return ([self.expirationDate timeIntervalSinceNow] < 0);
}

- (BOOL)isNotEmpty
{
    return (_accessToken.length > 0 && _refreshToken.length > 0 && _expirationDate != nil);
}

@end
