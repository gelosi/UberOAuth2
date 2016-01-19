Pod::Spec.new do |s|
  s.name         = "UberOAuth2"
  s.version      = "0.1"
  s.summary      = "UberOAuth2 - a iOS network debug library ,It can monitor HTTP requests within the App and displays information related to the request."
  s.homepage     = "https://github.com/uberHackason/UberOAuth2"
  s.license      = "MIT"
  s.authors      = { "coderyi" => "coderyi@163.com" }
  s.source       = { :git => "https://github.com/uberHackason/UberOAuth2.git", :tag => "0.1" }
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit'
  s.platform     = :ios, '7.0'
  s.source_files = 'UberOAuth2/UberOAuth2/**/*.{h,m,png}'
  s.requires_arc = true
  



 

end