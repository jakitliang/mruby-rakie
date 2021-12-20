
Rakie::Loop.dispatch do
  puts '123'
end

class Client
  attr_accessor :io

  def initialize
    @io = TCPSocket.new('127.0.0.1', 3001)
  end

  def on_read(io)
    begin
      data = io.recv_nonblock(100)

      puts "Receive [#{data.length}] bytes: #{data}"

    rescue Exception => e
      Log.debug("Channel error #{io}: #{e}")
      return Event::HANDLE_FAILED
    end

    return Event::HANDLE_CONTINUED
  end

  def on_write(io)
    
  end

  def on_detach(io)
    begin
      io.close

    rescue Exception => e
      p e
    end
  end
end

n = 1
c = Client.new

Rakie::Selector.instance.push(c.io, c, Rakie::Selector::READ_EVENT)

Rakie::Loop.run do
  c = n.clone

  Rakie::Loop.dispatch { puts "Start for #{c} times" }
  n += 1
end
