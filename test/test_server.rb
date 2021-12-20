
Rakie::Loop.dispatch do
  puts '123'
end

module Rakie
  class Client
    attr_accessor :io

    def initialize(io = nil)
      @io = io

      Rakie::Selector.instance.push(@io, self, Rakie::Selector::READ_EVENT)
    end

    def on_read(io)
      begin
        if io.eof?
          Log.debug("Channel #{io} closed by remote")
          return Selector::HANDLE_FAILED
        end

        data = io.recv_nonblock(100)

        puts "Receive [#{data.length}] bytes: #{data}"

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

Rakie::Loop.run do
  c = n.clone

  Rakie::Loop.dispatch { puts "Start for #{c} times" }
  n += 1
end
