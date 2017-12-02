#
#  Be sure to run `pod spec lint CPRefreshControl.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CPRefreshControl"
  s.version      = "0.0.9"
  s.summary      = "A customizable refresh control based on UIView."
  s.description  = "A customizable, UIView based refresh control to be used in conjugation with table views, collection views, or just about anything."
  s.homepage     = "https://github.com/canpoyrazoglu/CPRefreshControl"


  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  s.author             = { "Can Poyrazoğlu" => "can@canpoyrazoglu.com" }
  s.social_media_url   = "http://twitter.com/canpoyrazoglu"



  s.platform     = :ios, "6.0"


  s.source       = { :git => "https://github.com/canpoyrazoglu/CPRefreshControl.git", :tag => 'v0.0.9' }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


end
