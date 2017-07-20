//
//  UberAPI.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberAPI.h"

@implementation UberAPI

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)clientSecret apiURL:(NSURL *)apiURL loginURL:(NSURL *)loginURL
{
    self = [super init];
    
    if ( self) {
        _clientID = clientID.copy;
        _clientSecret = clientSecret.copy;
        _apiURL = apiURL.copy;
        _loginURL = loginURL.copy;
        _completionQueue = [NSOperationQueue mainQueue];
    }
    
    return self;
}

- (NSURL *)autorizationURLStringWithScope:(NSString *)scope
{
    NSURL *url = [self.loginURL URLByAppendingPathComponent:@"oauth/v2/authorize"];
    
    NSString *query=[NSString stringWithFormat:@"client_id=%@&response_type=code&scope=%@",_clientID, scope];
    
    if( self.redirectURL) {
        query = [query stringByAppendingFormat:@"&redirect_uri=%@", self.redirectURL];
    }
    
    NSURLComponents *componets = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
    componets.query = query;
    
    return componets.URL;
}

- (void)requestAccessTokenWithAuthorizationCode:(NSString *)code result:(UberAPILoginCompletion)requestResult
{
    NSURL *url = [self.loginURL URLByAppendingPathComponent:@"/oauth/v2/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBodyString=[NSString stringWithFormat:@"client_secret=%@&client_id=%@&grant_type=authorization_code&code=%@",_clientSecret, _clientID, code];
    
    if( self.redirectURL) {
        postBodyString = [postBodyString stringByAppendingFormat:@"&redirect_uri=%@", self.redirectURL];
    }
    
    NSData *bodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        UberAPIAccessToken *accessToken = [[UberAPIAccessToken alloc] initWithDictionary:responseObject];
        
        if( accessToken.isNotEmpty) {
            self.accessToken = accessToken;
        }
        
        if (requestResult) {
            [self.completionQueue addOperationWithBlock:^{
                requestResult(accessToken, error);
            }];

        }
        
    }];
    
    [task resume];
    
    
}

- (void)requestAccessTokenWithRefreshToken:(UberAPILoginCompletion)requestResult
{
    NSURL *url = [self.loginURL URLByAppendingPathComponent:@"/oauth/v2/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBodyString=[NSString stringWithFormat:@"client_secret=%@&client_id=%@&grant_type=refresh_token&refresh_token=%@",_clientSecret, _clientID, self.accessToken.refreshToken];
    
    if( self.redirectURL) {
        postBodyString = [postBodyString stringByAppendingFormat:@"&redirect_uri=%@", self.redirectURL];
    }
    
    NSData *bodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        UberAPIAccessToken *accessToken = [[UberAPIAccessToken alloc] initWithDictionary:responseObject];
        
        if( accessToken.isNotEmpty) {
            self.accessToken = accessToken;
        }
        
        if (requestResult) {
            [self.completionQueue addOperationWithBlock:^{
                requestResult(accessToken, error);
            }];

        }
        
    }];
    
    [task resume];
}

- (void)invalidateCurrentAccessToken:(UberAPILoginCompletion)requestResult
{
    NSURL *url = [self.loginURL URLByAppendingPathComponent:@"/oauth/v2/revoke"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBodyString=[NSString stringWithFormat:@"client_secret=%@&client_id=%@&token=%@",_clientSecret, _clientID, self.accessToken.accessToken];
    
    if( self.redirectURL) {
        postBodyString = [postBodyString stringByAppendingFormat:@"&redirect_uri=%@", self.redirectURL];
    }
    
    NSData *bodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if( !error) {
            self.accessToken = nil;
        }
        
        if (requestResult) {
            [self.completionQueue addOperationWithBlock:^{
                requestResult( self.accessToken, error);
            }];
        }
        
    }];
    
    [task resume];
}


- (void)requestUserProfileWithResult:(UberAPIRequestCompletion)requestResult
{
    NSURL *URL = [self.apiURL URLByAppendingPathComponent:@"/v1.2/me"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (requestResult) {
            [self.completionQueue addOperationWithBlock:^{
                requestResult(responseObject, error);
            }];
            
        }
        
    }];
    
    [task resume];
}

@end
