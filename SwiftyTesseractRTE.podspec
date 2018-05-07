Pod::Spec.new do |s|
  s.name             = 'SwiftyTesseractRTE'
  s.version          = '1.0.4'
  s.summary          = 'A real-time optical character recognition engine built on top of SwiftyTesseract.'

  s.description      = <<-DESC
                        SwiftyTesseractRTE is an out-of-the-box solution for real-time optical character recognition. 
                        Add SwiftyTesseractRTE to your project and you'll be performing OCR via a live camera 
                        feed in just a few lines of code.
                       DESC

  s.platform         = :ios, "11.0"
  s.homepage         = 'https://github.com/SwiftyTesseract/SwiftyTesseractRTE'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Steven Sherry' => 'steven.sherry@affinityforapps.com' }
  s.source           = { :git => 'https://github.com/SwiftyTesseract/SwiftyTesseractRTE.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/steven_0351'

  s.ios.deployment_target = '10.0'

  s.source_files = 'SwiftyTesseractRTE/Classes/**/*'

  s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'SwiftyTesseract', '~> 1.0'
end
