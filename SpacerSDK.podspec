Pod::Spec.new do |spec|
  spec.name         = "SpacerSDK"
  spec.version      = "1.3.0"
  spec.summary      = "IOS SDK for using SPACER locker"
  spec.homepage     = "https://github.com/spacer-dev/spacer-sdk-ios"
  spec.license      = "MIT"
  spec.author       = "SPACER Co., Ltd."
  spec.platform     = :ios, "10.2"
  spec.source       = { :git => "https://github.com/spacer-dev/spacer-sdk-ios.git", :tag => "#{spec.version}" }
  spec.dependency 'Alamofire', '~> 5.4.1'
  spec.source_files  = "Sources/**/*.{swift}"
  spec.swift_version = "5.0"
end
