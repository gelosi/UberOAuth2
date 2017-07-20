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

typedef void (^UberAPIRequestCompletion)(NSDictionary *responseObject, NSError *error);
typedef void (^UberAPILoginCompletion)(UberAPIAccessToken *accessToken, NSError *error);

@interface UberAPI : NSObject

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSURL *apiURL;
@property (nonatomic, readonly) NSURL *loginURL;

@property (nonatomic, copy, nullable) NSString *redirectURL;
@property (nonatomic, copy, nullable) UberAPIAccessToken *accessToken;

@property (nonatomic) NSOperationQueue *completionQueue; // default - mainQueue

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)clientSecret apiURL:(NSURL *)apiURL loginURL:(NSURL *)loginURL;

- (NSURL *)autorizationURLStringWithScope:(NSString *)scope;

- (void)requestAccessTokenWithAuthorizationCode:(NSString *)code result:(UberAPILoginCompletion)requestResult;

- (void)requestAccessTokenWithRefreshToken:(UberAPILoginCompletion)requestResult;

- (void)invalidateCurrentAccessToken:(UberAPILoginCompletion)requestResult;

- (void)requestUserProfileWithResult:(UberAPIRequestCompletion)requestResult;

@end

NS_ASSUME_NONNULL_END
