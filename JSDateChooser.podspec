Pod::Spec.new do |s|
  s.name         = "JSDateChooser"
  s.version      = "0.0.1"
  s.summary      = "A date picker for iOS."
  s.homepage     = "https://github.com/Joshua-Shen/JSDateChooser"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Joshua-Shen" => "shen_x_q@163.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Joshua-Shen/JSDateChooser.git", :tag => s.version }
  s.requires_arc = true
  s.public_header_files = 'JSDateChooser/JSDateChooser/JSDateChooser.h'
  s.source_files  = 'JSDateChooser/JSDateChooser/Classes/**/*.{h,m}'
  end

end
