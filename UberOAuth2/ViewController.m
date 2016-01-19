//
//  ViewController.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "ViewController.h"
#import "UberLoginWebViewController.h"
#import "UberAPI.h"


@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *loginBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBut];
    loginBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 100, 200, 50);
    loginBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [loginBut setTitle:@"Uber OAuth2 Login" forState:UIControlStateNormal];
    [loginBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBut addTarget:self action:@selector(loginButAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *requestUserProfileBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:requestUserProfileBut];
    requestUserProfileBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 200, 200, 50);
    requestUserProfileBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [requestUserProfileBut setTitle:@"Request User Profile" forState:UIControlStateNormal];
    [requestUserProfileBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestUserProfileBut addTarget:self action:@selector(requestUserProfileButAction) forControlEvents:UIControlEventTouchUpInside];

}

- (void)loginButAction{
    if (ClientId.length<1 || ClientSecret.length<1 || RedirectUrl.length<1 ) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret & redirecturl \n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];

    }
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    //    缓存  清除
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    UberLoginWebViewController *webViewController=[[UberLoginWebViewController alloc] init];
    NSString *url=[NSString stringWithFormat:@"https://login.uber.com.cn/oauth/v2/authorize?client_id=%@&redirect_url=%@&response_type=code&scope=profile history places history_lite",ClientId,RedirectUrl ];
    NSString *encodedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    webViewController.urlString=encodedUrlString;
    webViewController.resultCallBack=^(NSDictionary *jsonDict, NSURLResponse *response, NSError *error){
        NSLog(@"access token %@ ",jsonDict);
        
        if (error) {
            if ([error.domain isEqualToString:@"error2"]) {
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"login fail" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
                [alerView show];
            }
        }else{
            [self requestUserProfileButAction];
            
        }
        
    };
    
    [self presentViewController:webViewController animated:YES completion:nil];
}


- (void)requestUserProfileButAction{
    NSString *accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (!accessToken || accessToken.length<1) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"please login first" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:@"cancel", nil];
        [alerView show];
    }else{
        [self userProfileRequest];
    
    }
}

- (void)userProfileRequest{
    [UberAPI requestUserProfileWithResult:^(NSDictionary *jsonDict, NSURLResponse *response, NSError *error){
        NSLog(@"user profile %@ ",jsonDict);
        if (jsonDict) {
            // 主线程执行：
            dispatch_async(dispatch_get_main_queue(), ^{
                // something
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"uber user profile\n%@",jsonDict] delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
                [alerView show];

            });

        }
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self loginButAction];

    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
