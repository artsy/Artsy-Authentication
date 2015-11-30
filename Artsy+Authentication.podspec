Pod::Spec.new do |s|
  s.name             = "Artsy+Authentication"
  s.version          = "1.5.0"
  s.summary          = "Authentication for Artsy Services."
  s.description      = <<-DESC
                        Authentication for Artsy Cocoa libraries. Yawn, boring.
                        DESC
  s.homepage         = "https://github.com/artsy/Artsy_Authentication"
  s.license          = 'MIT'
  s.author           = { "Orta Therox" => "orta@artsymail.com" }
  s.source           = { :git => "https://github.com/artsy/Artsy_Authentication.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/artsyopensource'

  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'

  # Twitter/FB/Email
  s.subspec "Everything" do |ss|
    # Does not work with tvOS
    ss.tvos.deployment_target = "100.0"

    ss.source_files = 'Pod/Classes'
    ss.private_header_files = 'Pod/Classes/*Private.h'

    ss.ios.frameworks = 'Foundation', 'Social', 'Accounts'
    ss.ios.dependencies = { 'ISO8601DateFormatter' => "> 0", 'NSURL+QueryDictionary' => "> 0", 'LVTwitterOAuthClient' => "> 0" }
  end

  # Email
  s.subspec "EmailOnly" do |ss|
    ss.source_files = 'Pod/Classes'
    ss.private_header_files = 'Pod/Classes/*Private.h'
    ss.exclude_files = ['Pod/Classes/*Facebook.{h,m}', 'Pod/Classes/*Twitter.{h,m}']
    ss.tvos.exclude_files = ['Pod/Classes/*Facebook.{h,m}', 'Pod/Classes/*Twitter.{h,m}', 'Pod/Classes/*Accounts.{h,m}']
    ss.ios.dependencies = { 'ISO8601DateFormatter' => "> 0", 'NSURL+QueryDictionary' => "> 0" }
    ss.frameworks = 'Foundation'
  end

  s.default_subspec = "Everything"
end
