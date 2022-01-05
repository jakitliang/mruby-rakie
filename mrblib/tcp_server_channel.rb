module Rakie
  class TCPServerChannel < TCPChannel
    # @param host [String]
    # @param port [Integer]
    # @param delegate [Object]
    # @overload initialize(host, port, delegate)
    # @overload initialize(host, port)
    # @overload initialize(port)
    def initialize(host: LOCAL_HOST, port: 3001, delegate: nil)
      socket = nil
      
      if port == nil
        port = host
        host = LOCAL_HOST
      end
      
      socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
      socket.bind(Socket.pack_sockaddr_in(port, host))
      socket.listen(255)

      @clients = []

      super(host: host, port: port, delegate: delegate, socket: socket)
    end

    # @param io [Socket]
    def on_read(io)
      begin
        ret = io.accept
        # @type client_io [Socket]
        client_io = ret[0]
        # @type client_info [Addrinfo]
        client_info = ret[1]
        client_name_info = Socket.unpack_sockaddr_in(client_info)
        client_host = client_name_info[1]
        client_port = client_name_info[0]
        channel = TCPChannel.new(host: client_host, port: client_port, delegate: nil, socket: client_io)

        Log.debug("TCPServerChannel accept client #{client_host}:#{client_port}")

        if @delegate != nil
          Log.debug("TCPServerChannel has delegate")
          @delegate.on_accept(channel)

        else
          Log.debug("TCPServerChannel no delegate")
          @clients << channel
        end

        Log.debug("TCPServerChannel accept #{channel}")

      rescue Exception => e
        Log.debug("TCPServerChannel Accept failed #{io}: #{e}")
        return Selector::HANDLE_FAILED
      end

      return Selector::HANDLE_CONTINUED
    end

    def accept
      @clients.shift
    end
  end
end

# require "socket"