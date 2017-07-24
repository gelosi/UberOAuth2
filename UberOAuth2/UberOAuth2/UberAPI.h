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

/*! Completion queue to use to run user completion blocks
@remark default is <b>mainQueue</b>
 */
@property (nonatomic) NSOperationQueue *completionQueue;

/** default `sharedSession`
 */
/*! NSURLSession to run ALL API requests
 @remark default is <b>sharedSession</b>
 */
@property (nonatomic) NSURLSession *urlSession;

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)clientSecret apiURL:(NSURL *)apiURL loginURL:(NSURL *)loginURL;

- (NSURL *)autorizationURLStringWithScope:(NSString *)scope;

- (void)requestAccessTokenWithAuthorizationCode:(NSString *)code result:(UberAPILoginCompletion)requestResult;

- (void)requestAccessTokenWithRefreshToken:(UberAPILoginCompletion)requestResult;

- (void)invalidateCurrentAccessToken:(UberAPILoginCompletion)requestResult;

- (void)requestUserProfileWithResult:(UberAPIRequestCompletion)requestResult;

/** perform `request` by adding content-type application/json and setting proper Autorization header
 */
- (void)performAutorizedRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
