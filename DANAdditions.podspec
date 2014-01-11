Pod::Spec.new do |s|
  s.name         = "DANAdditions"
  s.version      = "0.0.2"
  s.summary      = "DANAdditions is a set of categories for various classes in Objective-C."
  s.homepage     = "https://github.com/endocrimes/DANAdditions"
  s.license      = 'MIT'
  s.author       = { "Danielle Lancashire" => "Dan@Tomlinson.io" }
  
  s.platform     = :ios
  
  s.source       = { :git => "https://github.com/endocrimes/DANAdditions.git", :tag => "0.0.2" }

  s.source_files = '*.{h,m}'

  s.requires_arc = true
end
