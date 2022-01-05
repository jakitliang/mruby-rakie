
class TestHttpApp
  def initialize
    @server = Rakie::HttpServer.new(host: '127.0.0.1', port: 3001, delegate: self)
  end

  def handle(request, response)
    p request

    response.headers["content-type"] = Rakie::HttpMIME::HTML
    response.content = "<html><body><h1>Hello test http app!</h1></body></html>"
  end
end

n = 1
s = TestHttpApp.new

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
