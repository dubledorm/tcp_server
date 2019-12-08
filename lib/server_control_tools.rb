module ServerControlTools

  def find_pair(port1, port2)
    $tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.has_pair?(port1.to_i, port2.to_i)}.first
  end

  def find_used_port(ports)
    [0, 1].each do |i|
      if use_port?(ports[i].to_i)
        return ports[i]
      end
    end
    nil
  end

  def start_tcp_server(ports, mode)
    tcp_server_control = TcpServer::TcpServerControl.new(ports.map{ |port| port.to_i}, mode)
    tcp_server_control.start
    $tcp_server_controls << tcp_server_control
  end

  def use_port?(port)
    $tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.has_port?(port) }.size != 0
  end

  def init_by_env_variable
    unless ENV['PAIRS_OF_SERVERS'].blank?
      puts(ENV['PAIRS_OF_SERVERS'])
      pairs = JSON.parse(ENV['PAIRS_OF_SERVERS'], symbolize_names: true)
      pairs.each do |pair|
        puts("<<<< #{pair[:pair]} >>>>")
        port = find_used_port(pair[:pair])

        if !port.nil?
          puts("ERROR! The port number #{port} already used")
        else
          start_tcp_server(pair[:pair], pair[:mode].nil? ? :smart : :dumb)
          puts("Started pair #{pair[:pair]}")
        end
      end
    end
  end
end