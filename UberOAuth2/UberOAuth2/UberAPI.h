//
//  UberAPI.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

@import Foundation;

#import "UberAPIAccessToken.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UberAPIResultBlock)(NSDictionary *responseObject, NSError *error);

@interface UberAPI : NSObject

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSURL *rootURL;

@property (nonatomic, copy, nullable) NSString *redirectURL;
@property (nonatomic, copy, nullable) UberAPIAccessToken *accessToken;

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)clientSecret rootURL:(NSURL *)rootURL;

- (NSURL *)autorizationURLStringWithScope:(NSString *)scope;

- (void)requestAccessTokenWithAuthorizationCode:(NSString *)code result:(UberAPIResultBlock)requestResult;

- (void)requestUserProfileWithResult:(UberAPIResultBlock)requestResult;

@end

NS_ASSUME_NONNULL_END
