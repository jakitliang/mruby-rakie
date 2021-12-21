
Rakie::Scheduler.dispatch do
  puts '123'
end

module Rakie
  class Client
    attr_accessor :io

    def initialize(io = nil)
      @io = io
      @buffer = String.new

      Rakie::Selector.instance.push(@io, self, Rakie::Selector::READ_EVENT)
    end

    def self.recv_nonblock(io, size)
      io.recv(size, Socket::MSG_DONTWAIT)
    end

    def self.send_nonblock(io, message)
      io.send(message, Socket::MSG_NOSIGNAL | Socket::MSG_DONTWAIT)
    end

    def on_read(io)
      begin
        data = Client.recv_nonblock(io, 100)

        puts "Receive [#{data.length}] bytes: #{data}"

        @buffer << data

        self.on_write(io)

        if data.length == 0
          Log.debug("Channel #{io} closed by remote")
          return Selector::HANDLE_FAILED if io.eof?
        end

      rescue Exception => e
        Log.debug("Channel error #{io}: #{e}")
        return Selector::HANDLE_FAILED
      end

      return Selector::HANDLE_CONTINUED
    end

    def on_write(io)
      begin
        len = Client.send_nonblock(io, @buffer)

        @buffer = @buffer[len .. -1]

      rescue
        Log.debug("Channel close #{io}")
        return Selector::HANDLE_FAILED
      end
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

  class Server
    attr_accessor :io

    def initialize
      @io = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
      @io.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
      @io.bind(Socket.pack_sockaddr_in(3001, '127.0.0.1'))
      @io.listen(255)

      @clients = []
    end

    def on_read(io)
      p 'Server is on accept'

      begin
        ret = io.accept_nonblock
        p ret
        # @type client_io [Socket]
        client_io = ret[0]
        # @type client_info [Addrinfo]
        client_info = ret[1]
        client = Client.new(client_io)

        @clients << client

        Log.debug("TCPServer accept #{client}")

      rescue Exception => e
        Log.debug("TCPServer Accept failed #{io}: #{e}")
        return Selector::HANDLE_FAILED
      end

      return Selector::HANDLE_CONTINUED
    end

    def on_write(io)
      
    end

    def on_detach(io)
      p 'Server close'

      begin
        io.close

      rescue Exception => e
        p e
      end
    end
  end
end

n = 1
s = Rakie::Server.new

Rakie::Selector.instance.push(s.io, s, Rakie::Selector::READ_EVENT)

Rakie::Scheduler.run do
  c = n.clone

  Rakie::Scheduler.dispatch { puts "Start for #{c} times" }
  n += 1
end
