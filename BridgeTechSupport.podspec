
Pod::Spec.new do |s|
  s.name             = 'BridgeTechSupport'
  s.version          = '0.1.0'
  s.summary          = 'Adds an amazing support menu bar to your app\'s menu. Really useful for all developers with any kind of app. 😉'

  s.description      = <<-DESC
  Prompts for users to sign up to your mailing list, using the MailGun API.
                       DESC

  s.homepage         = 'https://github.com/megatron1000/BridgeTechSupport'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'megatron1000' => 'mark@bridgetech.io' }
  s.source           = { :git => 'https://github.com/megatron1000/BridgeTechSupport.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/markbridgesapps'

  s.platform     = :osx, '10.11'
  s.swift_version = '4.2'

  s.source_files = 'BridgeTechSupport/Classes/**/*'
  s.resource_bundles = {}

end
