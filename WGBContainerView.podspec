Pod::Spec.new do |spec|
  spec.name         = "WGBContainerView"
  spec.version      = "1.0.1"
  spec.summary      = "A modern iOS container view SDK with Apple-style three-position interaction."
  spec.description  = <<-DESC
    WGBAppleContainerView is a modern iOS SDK that provides Apple Maps-like container interaction experience.
    Features include three-position stops, smooth animations, highly customizable configurations, 
    and support for multiple integration methods (Code/Xib/Nib).
  DESC

  spec.homepage     = "https://github.com/wangguibin/WGBContainerView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "CoderWGB" => "CoderWGB@163.com" }
  
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/wangguibin/WGBContainerView.git", :tag => "#{spec.version}" }
  
  spec.source_files = "Sources/WGBAppleContainerView/*.{h,m}"
  spec.public_header_files = "Sources/WGBAppleContainerView/*.h"
  
  spec.frameworks = "UIKit", "Foundation"
  spec.requires_arc = true
  
  spec.ios.deployment_target = "9.0"
end
