#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "CoreDataKit"
  s.version          = "0.1.0"
  s.summary          = "CoreDataKit makes common operations on objects and importing into CoreData a breeze."
  s.description      = <<-DESC
                       CoreDataKit makes common operations on objects and importing into CoreData a breeze.

                       * Easy CRUD operations, finding data and fetched results controllers
                       * Import data from NSDictionaries/NSArrays
                       * Still be able to customize and dive into CoreData when necessary
                       DESC
  s.homepage         = "http://github.com/mac-cain13/CoreDataKit"
  s.license          = 'MIT'
  s.author           = { "Mathijs Kadijk" => "mkadijk@gmail.com" }
  s.source           = { :git => "http://github.com/mac-cain13/CoreDataKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'CoreData'
end
