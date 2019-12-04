module ServerControlTools

  def find_pair(port1, port2)
    $tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.has_pair?(port1, port2)}.first
  end

  def find_used_port(ports)
    [0, 1].each do |i|
      if use_port?(ports[i])
        return ports[i]
      end
    end
    nil
  end

  def start_server(ports)
    tcp_server_control = TcpServer::TcpServerControl.new(ports)
    tcp_server_control.start
    $tcp_server_controls << tcp_server_control
  end

  def use_port?(port)
    $tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.has_port?(port) }.size != 0
  end
end