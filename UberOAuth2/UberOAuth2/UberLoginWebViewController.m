//
//  UberLoginWebViewController.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberLoginWebViewController.h"
#import "UberAPI.h"
@interface UberLoginWebViewController ()<UIWebViewDelegate>

@end

@implementation UberLoginWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:webView];
    webView.delegate = self;
    
    if( self.autorizationURL) {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:self.autorizationURL] ];
    } else {
        [self.delegate loginController:self didFailWithError:[NSError errorWithDomain:@"uber.login.no_autorization_url" code:500 userInfo:nil]];
    }

}
- (void)backBtAction
{
    [self.delegate loginControllerDidCancel:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldCheckForCode = self.uberAPI.redirectURL && [request.URL.absoluteString hasPrefix:self.uberAPI.redirectURL];
    
    if( shouldCheckForCode) {
        
        NSString *code = [self extractValueNamed:@"code" fromUrlQuery:request.URL];
        
        if( code) {
            [self requestAccessTokenActionWithCode:code];
            
            return NO; // no need to load the page
        }
    }
    
    // failure case https://login.uber.com/oauth/errors
    if( [request.URL.pathComponents containsObject:@"errors"]) {
        
        NSString *value = [self extractValueNamed:@"error" fromUrlQuery:request.URL];
        
        NSString *errorDomain = value ? [NSString stringWithFormat:@"uber.login.%@", value] : @"uber.login";
        
        NSError *error = [NSError errorWithDomain:errorDomain code:500 userInfo:nil];
        
        [self.delegate loginController:self didFailWithError:error];
    }
    
    return YES;
}


- (void)requestAccessTokenActionWithCode:(NSString *)code
{
    [self.uberAPI requestAccessTokenWithAuthorizationCode:code result:^(UberAPIAccessToken *accessToken, NSError *error){
        
        if( error == nil) {
            [self.delegate loginController:self didLoginWithToken:accessToken];
        } else {
            [self.delegate loginController:self didFailWithError:error];
        }
    }];
}

- (NSString *)extractValueNamed:(NSString *)name fromUrlQuery:(NSURL *)url
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    __block NSString *value;
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        if( [item.name isEqualToString:name]) {
            *stop = YES;
            value = item.value.copy;
        }
    }];

    return value;
}


@end
