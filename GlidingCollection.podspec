Pod::Spec.new do |s|
  s.name         = 'GlidingCollection'
  s.version      = '1.0.3'
  s.summary      = 'GlidingCollection'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/Ramotion/gliding-collection'
  s.author       = { 'Abdurahim Jauzee' => 'jauzee@ramotion.com' }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/Ramotion/gliding-collection.git', :tag => s.version.to_s }
  s.source_files  = 'GlidingCollection/**/*.swift'
end
