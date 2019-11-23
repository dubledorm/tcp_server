# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Thread.new do
  loop do
    TcpServer::TcpServerControl.start(3001, 3002)
    while TcpServer::TcpServerControl.pair_alive? do
      sleep(1)
    end
  end
end

