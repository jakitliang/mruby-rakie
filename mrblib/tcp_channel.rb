module Rakie
  class TCPChannel < Channel
    LOCAL_HOST = '127.0.0.1'

    # @param host [String]
    # @param port [Integer]
    # @param delegate [Object]
    # @param socket [Socket]
    # @overload initialize(host, port, delegate)
    # @overload initialize(host, port)
    # @overload initialize(host, port, delegate, socket)
    def initialize(host: LOCAL_HOST, port: 3001, delegate: nil, socket: nil)
      if socket == nil
        socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
        sock_addr = Socket.pack_sockaddr_in(port, host)

        begin
          socket.connect(sock_addr)
        rescue Exception => e
          Log.debug "Connect failed: #{e}"
        end
      end

      @port = port
      @host = host

      super(socket, delegate)
    end
  end
end

# require "socket"
