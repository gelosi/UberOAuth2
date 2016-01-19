//
//  UberAPI.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ClientId @"R5SJb3rtHiODnni8qR8VJqKO4lPmCj68"
#define ClientSecret @"2hWclaJLdBAnrFcqiv7xieGR88edC-q0FVF9CKUj"
#define RedirectUrl @"https://github.com/coderyi"

typedef void (^ RequestResult)(NSDictionary *jsonDict, NSURLResponse *response, NSError *error);

@interface UberAPI : NSObject

+ (void)requestAccessTokenWithAuthorationCode:(NSString *)code result:(void(^)(NSDictionary *jsonDict, NSURLResponse *response, NSError *error))requestResult;

+ (void)requestUserProfileWithResult:(void(^)(NSDictionary *jsonDict, NSURLResponse *response, NSError *error))requestResult;
@end
