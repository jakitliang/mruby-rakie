
Rakie::Scheduler.dispatch do
  puts '123'
end

n = 1

class Server
  def initialize
    @s = Rakie::TCPServerChannel.new(host: '127.0.0.1', port: 3001, delegate: self)
    @cs = []
  end

  def on_accept(channel)
    channel.delegate = self
    @cs << channel
  end

  def on_recv(channel, data)
    Rakie::Log.debug("Server recv message from #{channel}: #{data}")

    channel.write(data)

    return data.length
  end

  def on_send(channel)
    Rakie::Log.debug("Server response to #{channel} finished")
  end

  def on_close(channel)
    Rakie::Log.debug("Server close connection with #{channel}")
  end
end

s = Server.new

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
