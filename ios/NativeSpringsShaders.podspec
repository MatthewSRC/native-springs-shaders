require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'NativeSpringsShaders'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.9'
  s.source         = { git: 'https://github.com/MatthewSRC/native-springs-shaders' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'MTL_ENABLE_DEBUG_INFO' => 'INCLUDE_SOURCE',
    'MTL_FAST_MATH' => 'YES'
  }

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"

  # Metal shaders and overlays - specify them separately so they get compiled
  s.resources = ["Common.metal", "Shaders/*.metal", "Overlays/*.metal"]

  s.frameworks = 'Metal', 'MetalKit'
end
