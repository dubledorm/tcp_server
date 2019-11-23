module TcpServer
  class TcpServerControl
    def self.start(one_port, two_port)
      @threads = []
      tcp_server1 = TcpServer::SimpleTcpServer.new(one_port)
      tcp_server2 = TcpServer::SimpleTcpServer.new(two_port)

      @threads[0] = Thread.new do
        Thread.handle_interrupt(Exception => :immediate) do
          tcp_server1.call(tcp_server2)
        end
        Thread.handle_interrupt(Exception => :never) do
          Thread.current.report_on_exception = false
          Rails.logger.info('stop TcpServer on port ' + one_port.to_s)
          stop_pair_server(@threads[1])
        end
      end

      @threads[1] = Thread.new do
        Thread.handle_interrupt(Exception => :immediate) do
          tcp_server2.call(tcp_server1)
        end
        Thread.handle_interrupt(Exception => :never) do
          Thread.current.report_on_exception = false
          Rails.logger.info('stop TcpServer on port ' + two_port.to_s)
          stop_pair_server(@threads[0])
        end
      end
    end

    def self.stop
      @threads.each do |thread|
        thread.raise('restart')
      end
      sleep(1)
    end

    def self.stop_pair_server(pair_thread)
      return if pair_thread.nil?
      return unless pair_thread.alive?
      pair_thread.raise('restart')
    end

    def self.pair_alive?
      @threads[0].alive? || @threads[1].alive?
    end
  end
end