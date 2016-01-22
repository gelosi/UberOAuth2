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
platform :ios, '7.0'
pod 'UberOAuth2', '~> 0.1.1'
```


####Instruction
OAuth2 login
<pre>
	UberLoginWebViewController *webViewController=[[UberLoginWebViewController alloc] init];
    NSString *urlString=[NSString stringWithFormat:@"https://login.uber.com.cn/oauth/v2/authorize?client_id=%@&redirect_url=%@&response_type=code&scope=profile history places history_lite",ClientId,RedirectUrl ];
    NSString *encodedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    webViewController.urlString=encodedUrlString;
    webViewController.resultCallBack=^(NSDictionary *jsonDict, NSURLResponse *response, NSError *error){
        NSLog(@"access token %@ ",jsonDict);
    };
    [self presentViewController:webViewController animated:YES completion:nil];

</pre>


get user profile through accesstoken

<pre>
    [UberAPI requestUserProfileWithResult:^(NSDictionary *jsonDict, NSURLResponse *response, NSError *error){
        NSLog(@"user profile %@ ",jsonDict);
    }];

</pre>
####Uber OAuth2 Flow

<img  src="https://github.com/uberHackathon/UberOAuth2/blob/master/uberoauth2.png" width="421" height="365">





#### Licenses

All source code is licensed under the [MIT License](https://github.com/by-the-way/UberOAuth2/blob/master/LICENSE).

