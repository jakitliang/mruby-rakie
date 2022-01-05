
socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
sock_addr = Socket.pack_sockaddr_in(3001, '127.0.0.1')

begin
  socket.connect(sock_addr)
  
rescue Exception => e
  p "Connect failed: #{e}"
end

while true
  if IO.select([socket], nil, nil, 1)
    data = socket.recv(100, Socket::MSG_DONTWAIT)
    p data
    socket.send(data, Socket::MSG_DONTWAIT | Socket::MSG_NOSIGNAL)
  end
end
