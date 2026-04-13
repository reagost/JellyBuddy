Pod::Spec.new do |s|
  s.name             = 'jelly_llm'
  s.version          = '0.1.0'
  s.summary          = 'Cross-platform local LLM inference plugin'
  s.description      = 'On-device LLM inference for JellyBuddy using MLX on Apple platforms'
  s.homepage         = 'https://github.com/jellybuddy/jelly_llm'
  s.license          = { :type => 'MIT' }
  s.author           = { 'JellyBuddy' => 'dev@jellybuddy.app' }
  s.source           = { :path => '.' }
  # Only compile the plugin bridge file via CocoaPods.
  # The LLM/ directory requires MLX (SPM-only) and is compiled via Package.swift.
  s.source_files     = 'Classes/JellyLlmPlugin.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '17.0'
  s.swift_version    = '5.10'
  s.preserve_paths   = 'InferenceKit/**/*', 'Package.swift', 'Classes/LLM/**/*'
end
