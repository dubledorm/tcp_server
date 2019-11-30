# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

pairs = JSON.parse(ENV['PAIRS_OF_SERVERS'], symbolize_names: true)
Rails.logger.info("Got configuration: #{pairs}")

$tcp_server_control = TcpServer::TcpServerControl.new
$tcp_server_control.start(pairs[:pair])
