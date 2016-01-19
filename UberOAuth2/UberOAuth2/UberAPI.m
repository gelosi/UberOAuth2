//
//  UberAPI.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberAPI.h"

@implementation UberAPI
+ (void)requestAccessTokenWithAuthorationCode:(NSString *)code result:(void(^)(NSDictionary *jsonDict, NSURLResponse *response, NSError *error))requestResult{
        NSURL *url = [NSURL URLWithString:@"https://login.uber.com.cn/oauth/v2/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBodyString=[NSString stringWithFormat:@"client_secret=%@&client_id=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",@"2hWclaJLdBAnrFcqiv7xieGR88edC-q0FVF9CKUj",@"R5SJb3rtHiODnni8qR8VJqKO4lPmCj68",@"https://github.com/coderyi",code];
    
    NSData *bodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"access_token"] forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (requestResult) {
            requestResult(responseObject,response,error);
        }
        
    }];
    
    [task resume];
    
    
}


+ (void)requestUserProfileWithResult:(void(^)(NSDictionary *jsonDict, NSURLResponse *response, NSError *error))requestResult{
    
    
    NSURL *URL = [NSURL URLWithString:@"https://api.uber.com.cn/v1/me"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (requestResult) {
            requestResult(responseObject,response,error);
        }
        
    }];
    
    [task resume];
    
    
}

@end
