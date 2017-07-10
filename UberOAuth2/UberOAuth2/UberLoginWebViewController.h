//
//  UberLoginWebViewController.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UberAPI;

@interface UberLoginWebViewController : UIViewController
@property(nonatomic,strong) NSURL *autorizationURL;//LoginWebViewController 's url
@property(nonatomic) UberAPI *uberAPI;
@property(nonatomic,copy) void (^resultCallBack) (NSDictionary *jsonDict, NSError *error);// login callback

@end
