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
    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 20, 200, 44)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont systemFontOfSize:19.0]];
    titleText.textAlignment=NSTextAlignmentCenter;
    titleText.text=@"Uber OAuth2";
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 64)];
    [self.view addSubview:bar];
    bar.barTintColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [bar addSubview:titleText];

    UIButton *backBt=[UIButton buttonWithType:UIButtonTypeCustom];
    backBt.frame=CGRectMake(10, 27, 35, 30);
    [backBt setTitle:@"back" forState:UIControlStateNormal];
    backBt.titleLabel.font=[UIFont systemFontOfSize:15];
    [backBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBt addTarget:self action:@selector(backBtAction) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:backBt];
    
    UIWebView *webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    [self.view addSubview:webView];
    webView.delegate=self;
    if( self.autorizationURL) {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:self.autorizationURL] ];
    }

}
- (void)backBtAction
{
    if (_resultCallBack) {
        NSError *aError = [NSError errorWithDomain:@"error1" code:1 userInfo:nil];
        _resultCallBack(nil,aError);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
        NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        
        __block NSString *code;
        
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
            if( [item.name isEqualToString:@"code"]) {
                *stop = YES;
                code = item.value.copy;
            }
        }];
        
        if( code) {
            [self requestAccessTokenActionWithCode:code];
            
            
            return NO; // no need to load the page
        }
    }
    
    
    return YES;
}


- (void)requestAccessTokenActionWithCode:(NSString *)code
{
    [self.uberAPI requestAccessTokenWithAuthorizationCode:code result:^(NSDictionary *jsonDict, NSError *error){
        
        if (_resultCallBack) {
            if (jsonDict) {
                _resultCallBack(jsonDict,nil);

            }else{
                NSError *aError = [NSError errorWithDomain:@"error2" code:2 userInfo:nil];

                _resultCallBack(jsonDict,aError);

            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];

    }];

}


@end
