MRuby::Gem::Specification.new('mruby-rakie') do |spec|
  spec.license = 'BSD 2-Clause License'
  spec.authors = 'Jakit Liang'
  spec.version = '0.0.1'
  spec.summary = 'mruby-rakie is a high performance event-driven server and client framework in embedded situation.'
  spec.add_dependency('mruby-sha1', :core => 'mruby-sha1')
  spec.add_dependency('mruby-base64', :core => 'mruby-base64')
  spec.add_dependency('mruby-errno', :core => 'mruby-errno')
  spec.rbfiles = []
  spec.rbfiles << "#{dir}/mrblib/log.rb"
  spec.rbfiles << "#{dir}/mrblib/selector.rb"
  spec.rbfiles << "#{dir}/mrblib/scheduler.rb"
  spec.rbfiles << "#{dir}/mrblib/channel.rb"
  spec.rbfiles << "#{dir}/mrblib/tcp_channel.rb"
  spec.rbfiles << "#{dir}/mrblib/tcp_server_channel.rb"
  spec.rbfiles << "#{dir}/mrblib/proto.rb"
  spec.rbfiles << "#{dir}/mrblib/http_proto.rb"
  spec.rbfiles << "#{dir}/mrblib/websocket_proto.rb"
  spec.rbfiles << "#{dir}/mrblib/http.rb"
  spec.rbfiles << "#{dir}/mrblib/http_server.rb"
  spec.rbfiles << "#{dir}/mrblib/websocket.rb"
  spec.rbfiles << "#{dir}/mrblib/websocket_server.rb"
end
