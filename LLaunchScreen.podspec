Pod::Spec.new do |s|
  s.name             = 'LLaunchScreen'
  s.version          = '0.1.0'
  s.summary          = 'Dynamically modify the iOS Launch Image'
  s.homepage         = 'https://github.com/internetwei/LLaunchScreen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'internetwei' => 'internetwei@foxmail.com' }
  s.source           = { :git => 'https://github.com/internetwei/LLaunchScreen.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'LLaunchScreen/*'
end
