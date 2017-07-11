# UberOAuth2
[![Pod Version](http://img.shields.io/cocoapods/v/UberOAuth2.svg?style=flat)](http://cocoadocs.org/docsets/UberOAuth2/)
[![Pod Platform](http://img.shields.io/cocoapods/p/UberOAuth2.svg?style=flat)](http://cocoadocs.org/docsets/UberOAuth2/)
[![Pod License](http://img.shields.io/cocoapods/l/UberOAuth2.svg?style=flat)](https://opensource.org/licenses/MIT)


UberOAuth2 is a simple Objective-C wrapper for Uber OAuth2 login.

the Uber API url is <a href = https://developer.uber.com/docs/api-overview> Uber API </a>.

UberOAuth2 is used for uber.com.cn,but also can be used for uber.com .and you need register [uber developer](https://developer.uber.com.cn) , you need set 
clientid and clientsecret,redirecturl,and so on.

#### Podfile

```ruby
platform :ios, '8.0'
pod 'UberOAuth2', '~> 0.3'
```

#### Instruction
OAuth2 login
```objective-c

    _uberAPI = [[UberAPI alloc] initWithClientID:@""
                                          secret:@""
                                          apiURL:[NSURL URLWithString:@"https://api.uber.com"]
                                        loginURL:[NSURL URLWithString:@"https://login.uber.com"]];


    UberLoginWebViewController *webViewController=[[UberLoginWebViewController alloc] init];
    
    webViewController.autorizationURL = [self.uberAPI autorizationURLStringWithScope:@"profile history places history_lite"];
    webViewController.uberAPI = self.uberAPI;
    webViewController.title = @"Uber OAuth2";
    webViewController.delegate = self;

    [self presentViewController:webViewController animated:YES completion:nil];

```


get user profile through accesstoken

```objective-c

    // let's say you store token in the user defaults (because you can!)
    NSData *tokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"UberAccessToken"];
    UberAPIAccessToken *token = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];

    // so, you didn't crash at the point above... so you assign token, and you can try...

    _uberAPI.accessToken = token;
    

    [_uberAPI requestUserProfileWithResult:^(NSDictionary *jsonDict, NSError *error){
        NSLog(@"user profile %@ ",jsonDict);
        if (jsonDict) {
            //// 主线程执行：
            .....
            });

        }
        
    }];

```

#### Uber OAuth2 Flow

<img  src="https://github.com/uberHackathon/UberOAuth2/blob/master/uberoauth2.png" width="421" height="365">





#### Licenses

All source code is licensed under the [MIT License](https://github.com/by-the-way/UberOAuth2/blob/master/LICENSE).
