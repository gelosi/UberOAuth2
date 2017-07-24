//
//  UberLoginWebViewController.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberLoginWebViewController.h"
#import "UberAPI.h"

static NSInteger const PlaceholderViewTag = 0xBAD1DEA;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.loadingView) {
        [self installPlaceholderLoadingView];
        
        UIView *placeholder = [self placeholderLoadingView];
        
        if(placeholder.subviews.firstObject != self.loadingView) {
            [placeholder.subviews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger i, BOOL *stop) {
                [v removeFromSuperview];
            }];
            
            [placeholder addSubview:self.loadingView];
            
            NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            
            NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
            
            [placeholder addConstraints:@[centerX, centerY]];
            
            [self.view layoutIfNeeded];
        }
    }
}

- (void)backBtAction
{
    [self.delegate loginControllerDidCancel:self];
}

- (void)installPlaceholderLoadingView
{
    UIView *placeholder = [self placeholderLoadingView];
    
    if(!placeholder) {
        placeholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        placeholder.translatesAutoresizingMaskIntoConstraints = NO;
        placeholder.tag = PlaceholderViewTag;
        placeholder.clipsToBounds = NO;
        
        [self.view addSubview:placeholder];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:1];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:1];
        
        [self.view addConstraints:@[centerX, centerY, height, width]];
    }
}



- (UIView *)placeholderLoadingView
{
    UIView *placeholder;
    
    for( UIView *view in self.view.subviews) {
        if(!placeholder && ![view isKindOfClass:UIWebView.class] && view.tag == PlaceholderViewTag) {
            placeholder = view;
        }
    }
    
    return placeholder;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldCheckForCode = YES;
    
    NSError *error;
    
    NSString *errorString = [self extractValueNamed:@"error" fromUrlQuery:request.URL];
    
    if( errorString) {
        NSString *errorDomain = [NSString stringWithFormat:@"uber.login.%@", errorString];
        error = [NSError errorWithDomain:errorDomain code:500 userInfo:nil];
    }
    
    
    // failure case https://login.uber.com/oauth/errors
    NSSet *errors = [NSSet setWithObjects:@"error", @"errors", nil];
    NSSet *components = [NSSet setWithArray:request.URL.pathComponents];
    
    if( [components intersectsSet:errors]) {
        
        NSString *value = [self extractValueNamed:@"error" fromUrlQuery:request.URL];
        
        NSString *errorDomain = value ? [NSString stringWithFormat:@"uber.login.%@", value] : @"uber.login";
        
        NSDictionary *underlyingError = nil;
        if( error) {
            underlyingError = @{NSUnderlyingErrorKey : error };
        }

        error = [NSError errorWithDomain:errorDomain code:500 userInfo:underlyingError];
    }
    
    if( self.uberAPI.redirectURL) {
        shouldCheckForCode = [request.URL.absoluteString hasPrefix:self.uberAPI.redirectURL];
    }
    
    if( error) {
        [self.delegate loginController:self didFailWithError:error];
        shouldCheckForCode = NO;
    }
    
    if( shouldCheckForCode) {
        
        NSString *code = [self extractIdioticallyFormattedUberAutorizationCodeFromUrl:request.URL];
        
        if( code) {
            [self requestAccessTokenActionWithCode:code];
            
            return NO; // no need to load the page
        }
    }

    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if( self.loadingView) {
        self.loadingView.hidden = NO;
        self.loadingView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.loadingView.alpha = 1;
        }] ;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if( self.loadingView) {
        [UIView animateWithDuration:0.1 animations:^{
            self.loadingView.alpha = 0;
        } completion:^(BOOL finished) {
            self.loadingView.hidden = YES;
        }] ;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if( self.loadingView) {
        [UIView animateWithDuration:0.1 animations:^{
            self.loadingView.alpha = 0;
        } completion:^(BOOL finished) {
            self.loadingView.hidden = YES;
        }] ;
    }
    
    [self.delegate loginController:self didFailWithError:error];
}


#pragma mark - token request stuff

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

- (NSString *)extractIdioticallyFormattedUberAutorizationCodeFromUrl:(NSURL *)url
{
    // Uber saiz:
    // https://your-redirect-uri/?code=AUTHORIZATION_CODE
    // Uber does:
    // https://your-redirect-uri/?code=abcabc#_ <- yes! #_ - is a part of code!!!!
    // Conclusion: ****rs!
    
    NSString *potentialCode = [self extractValueNamed:@"code" fromUrlQuery:url];
    
    if( potentialCode) {
        NSString *realCode = [url.absoluteString componentsSeparatedByString:@"?code="].lastObject;
        
        // just because, you know... Uber...
        realCode = [realCode componentsSeparatedByString:@"&"].firstObject;
        
        return realCode;
    }
    
    return nil;
}


@end
