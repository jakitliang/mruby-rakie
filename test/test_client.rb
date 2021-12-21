
Rakie::Scheduler.dispatch do
  puts '123'
end

module Rakie
  class Client
    attr_accessor :io

    def initialize
      @io = TCPSocket.new('127.0.0.1', 3001)
    end

    def self.remote_closed?(io)
      status = false

      io._setnonblock(true)
      status = io.eof?
      io._setnonblock(false)

      return status
    end

    def on_read(io)
      begin
        data = io.recv_nonblock(100)

        puts "Receive [#{data.length}] bytes: #{data}"

        if data.length == 0
          Log.debug("Channel #{io} closed by remote")
          return Selector::HANDLE_FAILED if Client.remote_closed?(io)
        end

      rescue Exception => e
        Log.debug("Channel error #{io}: #{e}")
        return Selector::HANDLE_FAILED
      end

      return Selector::HANDLE_CONTINUED
    end

    def on_write(io)
      
    end

    def on_detach(io)
      begin
        Log.debug("Channel #{io} close")
        io.close

      rescue Exception => e
        p e
      end
    end
  end
end

n = 1
c = Client.new

Rakie::Selector.instance.push(c.io, c, Rakie::Selector::READ_EVENT)

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
