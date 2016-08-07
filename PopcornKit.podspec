Pod::Spec.new do |s|
  s.name = "PopcornKit"
  s.version = "1.1.0"
  s.summary = "The backend for the PopcornTime tvOS App"
  s.homepage = "https://github.com/popcornMaster/PopcornKit"
  s.license = 'MIT'
  s.author = { "popcornMaster" => "popcorn@time.tv" }
  s.source = { :git => "https://github.com/popcornMaster/PopcornKit.git", :tag => s.version }

  s.platforms = { :ios => "9.0", :tvos => "9.0" }
  s.requires_arc = true

  s.source_files = 'PopcornKit/**/*.{swift}'

  s.frameworks = 'UIKit', 'Foundation'
  s.module_name = 'PopcornKit'

  s.dependency 'Alamofire'
  s.dependency 'ObjectMapper'
  s.dependency 'SWXMLHash'
end
