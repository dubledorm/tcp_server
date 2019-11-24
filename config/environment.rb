# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

$tcp_server_control = TcpServer::TcpServerControl.new
$tcp_server_control.start([3001, 3002])

# Thread.new do
#   loop do
#     $tcp_server_control.start_pair([3001, 3002])
#     sleep(1) while $tcp_server_control.pair_alive?
#   end
# end

