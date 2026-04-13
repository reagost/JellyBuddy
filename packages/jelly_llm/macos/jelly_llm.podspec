Pod::Spec.new do |s|
  s.name             = 'jelly_llm'
  s.version          = '0.1.0'
  s.summary          = 'Cross-platform local LLM inference plugin'
  s.description      = 'On-device LLM inference for JellyBuddy using MLX on macOS'
  s.homepage         = 'https://github.com/jellybuddy/jelly_llm'
  s.license          = { :type => 'MIT' }
  s.author           = { 'JellyBuddy' => 'dev@jellybuddy.app' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '14.0'
  s.osx.deployment_target = '14.0'
  s.swift_version    = '5.10'
end
