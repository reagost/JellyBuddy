#!/usr/bin/env ruby
# ============================================================
# Add InferenceKit local SPM package to Runner.xcodeproj
# ============================================================
#
# This script automates what you'd do in Xcode:
#   File → Add Package → Add Local → ios/Packages/InferenceKit
#   Then link MLXLLM, MLXVLM, MLXLMCommon to Runner target
#
# Usage:
#   ruby scripts/setup_xcode_spm.rb
#
# Requires: xcodeproj gem (`gem install xcodeproj`)
# ============================================================

require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/Runner.xcodeproj', __dir__)
INFERENCE_KIT_PATH = '../Packages/InferenceKit'

puts "Opening #{PROJECT_PATH}..."
project = Xcodeproj::Project.open(PROJECT_PATH)

# Find Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }
abort("Runner target not found") unless runner_target

# Check if InferenceKit already added
existing = project.root_object.local_packages.find { |p| p.relative_path == INFERENCE_KIT_PATH }
if existing
  puts "InferenceKit already added to project. Skipping."
else
  puts "Adding InferenceKit local package..."
  # Add local package reference
  local_pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
  local_pkg.relative_path = INFERENCE_KIT_PATH
  project.root_object.local_packages << local_pkg

  # Add product dependencies to Runner target
  %w[MLXLLM MLXVLM MLXLMCommon].each do |product_name|
    dep = runner_target.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    dep.product_name = product_name
    dep.package = local_pkg
    runner_target.package_product_dependencies << dep

    # Also add to frameworks build phase
    build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
    build_file.product_ref = dep
    runner_target.frameworks_build_phase.files << build_file

    puts "  Linked #{product_name}"
  end
end

# Add LLM Swift files to Runner target (if not already there)
llm_dir = File.expand_path('../ios/Runner/LLM', __dir__)
runner_group = project.main_group.find_subpath('Runner', true)

llm_group = runner_group.find_subpath('LLM', false)
unless llm_group
  puts "Adding LLM group to project..."
  llm_group = runner_group.new_group('LLM', 'LLM')

  # Add all subdirectories
  Dir.glob(File.join(llm_dir, '**', '*.swift')).each do |swift_file|
    relative = swift_file.sub("#{llm_dir}/", '')
    parts = relative.split('/')

    # Navigate/create subgroups
    current_group = llm_group
    if parts.length > 1
      parts[0..-2].each do |dir|
        sub = current_group.find_subpath(dir, false)
        sub ||= current_group.new_group(dir, dir)
        current_group = sub
      end
    end

    # Add file reference
    file_ref = current_group.new_file(swift_file)
    runner_target.source_build_phase.add_file_reference(file_ref)
    puts "  Added #{relative}"
  end
end

# Add MLXBridge.swift if not in project
mlx_bridge_path = File.expand_path('../ios/Runner/MLXBridge.swift', __dir__)
unless runner_group.files.any? { |f| f.real_path.to_s.include?('MLXBridge.swift') }
  file_ref = runner_group.new_file(mlx_bridge_path)
  runner_target.source_build_phase.add_file_reference(file_ref)
  puts "  Added MLXBridge.swift"
end

# Set deployment target to iOS 17 for the Runner target
runner_target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
end

# Enable increased memory limit entitlement (needed for LLM)
# (Already in PhoneClaw.entitlements, ensure Runner has it)

project.save
puts "\n✅ Xcode project updated successfully!"
puts "\nNext steps:"
puts "  1. Open ios/Runner.xcworkspace in Xcode"
puts "  2. Wait for SPM to resolve mlx-swift (~2 min)"
puts "  3. Build & run on a real device"
puts "  4. Download Gemma 4 E2B model via the app"
