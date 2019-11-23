# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Thread.new do
  loop do
    TcpServer::TcpServerControl.start(3001, 3002)
    while $threads[0].alive? && $threads[1].alive? do
      sleep(1)
    end
  end
end

