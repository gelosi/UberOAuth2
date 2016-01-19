Pod::Spec.new do |s|
  s.name         = "UberOAuth2"
  s.version      = "0.1.1"
  s.summary      = "UberOAuth2 - UberOAuth2 is a simple Objective-C wrapper for Uber OAuth2 login."
  s.homepage     = "https://github.com/uberHackathon/UberOAuth2"
  s.license      = "MIT"
  s.authors      = { "coderyi" => "coderyi@163.com" }
  s.source       = { :git => "https://github.com/uberHackathon/UberOAuth2.git", :tag => "0.1.1" }
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit'
  s.platform     = :ios, '7.0'
  s.source_files = 'UberOAuth2/UberOAuth2/**/*.{h,m,png}'
  s.requires_arc = true
  



 

end