# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

$tcp_server_control = TcpServer::TcpServerControl.new
$tcp_server_control.start([3001, 3002])



