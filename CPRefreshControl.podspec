Pod::Spec.new do |s|

  s.name         = "CPRefreshControl"
  s.version      = "0.0.12"
  s.summary      = "A customizable refresh control based on UIView."
  s.description  = "A customizable, UIView based refresh control to be used in conjugation with table views, collection views, or just about anything."
  s.homepage     = "https://github.com/canpoyrazoglu/CPRefreshControl"

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "Can Poyrazoğlu" => "can@canpoyrazoglu.com" }
  s.social_media_url   = "http://twitter.com/canpoyrazoglu"



  s.platform     = :ios, "6.0"


  s.source       = { :git => "https://github.com/canpoyrazoglu/CPRefreshControl.git", :tag => s.version.to_s }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.framework    = "QuartzCore"


end
