
Rakie::Scheduler.dispatch do
  puts '123'
end

n = 1

class Client
  def initialize
    @c = Rakie::TCPChannel.new(delegate: self)
  end

  def on_recv(channel, data)
    p data

    @c.write(data)

    return data.length
  end

  def on_send(channel)
    p 'message send done'
  end

  def on_close(channel)
    p 'Client is closed'
  end
end

c = Client.new

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
