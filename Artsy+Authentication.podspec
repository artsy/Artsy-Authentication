Pod::Spec.new do |s|
  s.name             = "Artsy+Authentication"
  s.version          = "1.0.0"
  s.summary          = "Authentication for Artsy Services."
  s.description      = <<-DESC
                        Authentication for Artsy Cocoa libraries. Yawn, boring.
                        DESC
  s.homepage         = "https://github.com/artsy/Artsy_Authentication"
  s.license          = 'MIT'
  s.author           = { "Orta Therox" => "orta.therox@gmail.com" }
  s.source           = { :git => "https://github.com/artsy/Artsy_Authentication.git"}
  s.social_media_url = 'https://twitter.com/artsy'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.private_header_files = 'Pod/Classes/*Private.h'
  s.frameworks = 'Foundation', 'Social', 'Accounts'
  s.dependencies = ['ISO8601DateFormatter', 'NSURL+QueryDictionary', 'TwitterReverseAuth', 'AFNetworking']
end
