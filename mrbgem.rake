MRuby::Gem::Specification.new('mruby-rakie') do |spec|
  spec.license = 'BSD 2-Clause License'
  spec.authors = 'Jakit Liang'
  spec.version = '0.0.1'
  spec.summary = 'mruby-rakie is a high performance event-driven server and client framework in embedded situation.'
  spec.add_dependency('mruby-sha1', :core => 'mruby-sha1')
  spec.add_dependency('mruby-base64', :core => 'mruby-base64')
  spec.add_dependency('mruby-errno', :core => 'mruby-errno')
end
