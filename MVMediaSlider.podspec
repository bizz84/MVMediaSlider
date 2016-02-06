Pod::Spec.new do |s|
  s.name         = 'MVMediaSlider'
  s.version      = '0.0.2'
  s.summary      = 'Custom media slider inspired by the Overcast App'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/bizz84/MVMediaSlider'
  s.author       = { 'Andrea Bizzotto' => 'bizz84@gmail.com' }
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/bizz84/MVMediaSlider.git", :tag => s.version }

  s.source_files = 'MVMediaSlider/*.{swift,xib}'

  s.screenshots  = ["https://github.com/bizz84/MVMediaSlider/raw/master/Screenshots/MediaPlayer.png"]

  s.requires_arc = true
end
