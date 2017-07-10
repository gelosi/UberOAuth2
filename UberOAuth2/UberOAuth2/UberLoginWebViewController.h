//
//  UberLoginWebViewController.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UberAPI, UberAPIAccessToken;

@interface UberLoginWebViewController : UIViewController
@property(nonatomic,strong) NSURL *autorizationURL;//LoginWebViewController 's url
@property(nonatomic) UberAPI *uberAPI;
@property(nonatomic,copy) void (^resultCallBack) (UberAPIAccessToken *token, NSError *error);// login callback

@end
