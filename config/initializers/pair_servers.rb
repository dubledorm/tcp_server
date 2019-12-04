require 'server_control_tools'

include ServerControlTools

$tcp_server_controls = []
unless ENV['PAIRS_OF_SERVERS'].blank?
  puts(ENV['PAIRS_OF_SERVERS'])
  pairs = JSON.parse(ENV['PAIRS_OF_SERVERS'], symbolize_names: true)
  pairs.each do |pair|
    puts("<<<< #{pair[:pair]} >>>>")
    port = find_used_port(pair[:pair]).nil?

    if !port.nil?
      puts("ERROR! The port number #{port} already used")
    else
      start_server(pair[:pair])
      puts("Started pair #{pair[:pair]}")
    end
  end
end
