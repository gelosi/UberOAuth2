//
//  UberLoginWebViewController.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UberAPI, UberAPIAccessToken, UberLoginWebViewController;

@protocol UberLoginWebViewControllerDelegate <NSObject>

- (void)loginController:(UberLoginWebViewController *)controller didLoginWithToken:(UberAPIAccessToken *)token;
- (void)loginController:(UberLoginWebViewController *)controller didFailWithError:(NSError *)error;

- (void)loginControllerDidCancel:(UberLoginWebViewController *)controller;
@end

@interface UberLoginWebViewController : UIViewController
@property(nonatomic, strong) NSURL *autorizationURL;//LoginWebViewController 's url
@property(nonatomic) UberAPI *uberAPI;

@property(nonatomic, weak) id<UberLoginWebViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
