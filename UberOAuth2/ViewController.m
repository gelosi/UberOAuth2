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
@property (nonatomic) UberAPI *uberAPI;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *loginBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBut];
    loginBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 100, 200, 50);
    loginBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [loginBut setTitle:@"Uber OAuth2 Login" forState:UIControlStateNormal];
    [loginBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBut addTarget:self action:@selector(loginButAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *refreshTokenBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:refreshTokenBut];
    refreshTokenBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 200, 200, 50);
    refreshTokenBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [refreshTokenBut setTitle:@"Refresh Token" forState:UIControlStateNormal];
    [refreshTokenBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshTokenBut addTarget:self action:@selector(refreshTokenAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *requestUserProfileBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:requestUserProfileBut];
    requestUserProfileBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 300, 200, 50);
    requestUserProfileBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [requestUserProfileBut setTitle:@"Request User Profile" forState:UIControlStateNormal];
    [requestUserProfileBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestUserProfileBut addTarget:self action:@selector(requestUserProfileButAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *logoutUserBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:logoutUserBut];
    logoutUserBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 400, 200, 50);
    logoutUserBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [logoutUserBut setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutUserBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutUserBut addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    _uberAPI = [[UberAPI alloc] initWithClientID:@""
                                          secret:@""
                                          apiURL:[NSURL URLWithString:@"https://api.uber.com"]
                                        loginURL:[NSURL URLWithString:@"https://login.uber.com"]];
    
    _uberAPI.redirectURL = @"http://localhost";
    
    // read token, if any
    
    _uberAPI.accessToken = [self loadToken];
}

- (void)loginController:(UberLoginWebViewController *)controller didLoginWithToken:(UberAPIAccessToken *)token
{
    NSLog(@"access token %@ ",token.accessToken);
    
    // save token here, if needed
    
    [self saveToken:token];
    [self requestUserProfileButAction];
        
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginController:(UberLoginWebViewController *)controller didFailWithError:(NSError *)error
{
    UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alerView show];
}

- (void)loginControllerDidCancel:(UberLoginWebViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (UberAPIAccessToken *)loadToken
{
    UberAPIAccessToken *token;
    
    @try {
        token = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"UberAccessToken"]];
    } @catch (NSException *exception) {
        NSLog(@"Can not load token: %@", exception);
    }
    
    return token;
}

- (void)saveToken:(UberAPIAccessToken *)token
{
    if( token) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:token] forKey:@"UberAccessToken"];
    }
}

- (void)loginButAction
{
    if (self.uberAPI.clientSecret.length < 1 && self.uberAPI.clientID.length < 1 && self.uberAPI.redirectURL.length < 1) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret\n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;

    }
    
    UberLoginWebViewController *webViewController=[[UberLoginWebViewController alloc] init];
    
    
    webViewController.autorizationURL = [self.uberAPI autorizationURLStringWithScope:@"profile history places history_lite"];
    webViewController.uberAPI = self.uberAPI;
    webViewController.title = @"Uber OAuth2";
    webViewController.delegate = self;
    
    UILabel *loadingText = [UILabel new];
    
    loadingText.text = @"L O A D I N G";
    loadingText.backgroundColor = UIColor.lightGrayColor;
    loadingText.textColor = UIColor.whiteColor;
    loadingText.font = [UIFont boldSystemFontOfSize:22];
    loadingText.translatesAutoresizingMaskIntoConstraints = NO;
    loadingText.layer.cornerRadius = 6;
    loadingText.layer.masksToBounds = YES;
    [loadingText sizeToFit];
    
    webViewController.loadingView = loadingText;

    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)refreshTokenAction
{
    if (self.uberAPI.clientSecret.length < 1 && self.uberAPI.clientID.length < 1 && self.uberAPI.redirectURL.length < 1) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret\n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;
        
    }
    
    if (!self.uberAPI.accessToken.isNotEmpty) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you have no valid token. Login First!\n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;
        
    }

    
    [self.uberAPI requestAccessTokenWithRefreshToken:^(UberAPIAccessToken *accessToken, NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:@"error3"]) {
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"login with refresh token fail" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
                [alerView show];
            }
        }else{
            [self saveToken:accessToken];
            [self requestUserProfileButAction];
            
        }
    }];
}

- (void)logoutAction
{
    [self.uberAPI invalidateCurrentAccessToken:^(UberAPIAccessToken *accessToken, NSError *error) {
        
        NSString *message = @"Logout Successful";
        NSString *dialog = @"Bye bye";
        
        if (error) {
            message = error.localizedDescription;
            dialog = @"meh";
        }
        
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"logout" message:message delegate:nil cancelButtonTitle:dialog otherButtonTitles:nil, nil];
        [alerView show];

    }];
}


- (void)requestUserProfileButAction
{
    // guard #1
    if (self.uberAPI.clientSecret.length < 1 && self.uberAPI.clientID.length < 1 && self.uberAPI.redirectURL.length < 1) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret & redirecturl \n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;
    }

    // guard #2
    if (!self.uberAPI.accessToken.isNotEmpty) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"please login first" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:@"cancel", nil];
        [alerView show];
        return;
    }
    
    // guard #3
    if( self.uberAPI.accessToken.isExpired) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"Access token expired. Refresh token or login again?" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Token", nil];
        alerView.tag = 1; // this one has special dialor, right...
        [alerView show];
        return;
    }

    [self userProfileRequest];
}

- (void)userProfileRequest
{
    [self.uberAPI requestUserProfileWithResult:^(NSDictionary *jsonDict, NSError *error){
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag != 1 && buttonIndex==0) {
        [self loginButAction];
    }
    
    if( alertView.tag == 1 && buttonIndex == alertView.cancelButtonIndex) {
        [self loginButAction];
    }
    
    if( alertView.tag == 1 && buttonIndex != alertView.cancelButtonIndex) {
        [self refreshTokenAction];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
