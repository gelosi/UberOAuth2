//
//  UberAPI.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberAPI.h"

static NSDictionary * _Nullable JSONFromData(NSData * _Nullable data) {
    
    NSDictionary *responseObject;
    
    @try {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    } @catch (NSException *exception) {
        responseObject = nil;
    }
    
    return responseObject;
}

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
        _urlSession = [NSURLSession sharedSession];
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
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseObject = JSONFromData(data);
        
        UberAPIAccessToken *accessToken = [[UberAPIAccessToken alloc] initWithDictionary:responseObject];
        
        if( accessToken.isNotEmpty) {
            self.accessToken = accessToken;
        } else if(!error){
            NSInteger code = 500;
            
            if( [response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                code = httpResponse.statusCode;
            }
            
            NSString *errorString = responseObject[@"error"];
            
            if( errorString) {
                errorString = [@"uber.login." stringByAppendingString:errorString];
            } else {
                errorString = @"uber.login";
            }
            
            error = [NSError errorWithDomain:errorString code:code userInfo:nil];
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
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseObject = JSONFromData(data);
        
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
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

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
    
    [self performAutorizedRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = JSONFromData(data);
        if (requestResult) {
            [self.completionQueue addOperationWithBlock:^{
                requestResult(responseObject, error);
            }];
        }
    }];
}

- (void)performAutorizedRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion
{
    NSMutableURLRequest *autorizedRequest = request.mutableCopy;
    
    [autorizedRequest setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken.accessToken] forHTTPHeaderField:@"Authorization"];
    [autorizedRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:autorizedRequest completionHandler:completion];
    
    [task resume];
}

@end
