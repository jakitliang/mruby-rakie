
class TestWebSocketApp
  def initialize
    @server = Rakie::WebsocketServer.new(host: '127.0.0.1', port: 3001, delegate: self)
    @clients = []
  end

  def on_connect(ws)
    @clients << ws

    Rakie::Log.debug("Client join #{ws}")
  end

  def on_message(ws, message)
    Rakie::Log.debug("Client #{ws} message: #{message}")

    ws.send("You said: #{message}")
  end

  def on_disconnect(ws)
    @clients.delete(ws)
  end
end

n = 1
s = TestWebSocketApp.new

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
