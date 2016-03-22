Pod::Spec.new do |s|
  s.name         = "CoreDataKit"
  s.version      = "0.10.0"
  s.license      = "MIT"

  s.summary      = "CoreDataKit makes common operations on objects and importing into CoreData a breeze."

  s.description  = <<-DESC
CoreDataKit takes care of the hard and verbose parts of CoreData. It manages child contexts for you and helps to easily fetch, create and delete objects.
                   DESC

  s.authors           = { "Mathijs Kadijk" => "mkadijk@gmail.com" }
  s.social_media_url  = "http://twitter.com/mac_cain13"
  s.homepage          = "https://github.com/mac-cain13/CoreDataKit"

  s.source          = { :git => "https://github.com/mac-cain13/CoreDataKit.git", :tag => s.version }
  s.platform        = :ios, "8.0"
  s.requires_arc    = true
  s.source_files    = "CoreDataKit/**/*.swift"

end
