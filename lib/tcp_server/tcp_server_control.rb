module TcpServer
  class TcpServerControl
    def self.start(one_port, two_port)
      $threads = []
      tcp_server1 = TcpServer::SimpleTcpServer.new(one_port)
      tcp_server2 = TcpServer::SimpleTcpServer.new(two_port)

      $threads[0] = Thread.new do
        Thread.handle_interrupt(Exception => :immediate) {
          tcp_server1.call(tcp_server2)
        }
        puts('1111111111111111111111111 3001')
        Thread.handle_interrupt(Exception => :immediate) {
          stop_pair_server($threads[1])
        }
      end

      $threads[1] = Thread.new do
        Thread.handle_interrupt(Exception => :immediate) {
          tcp_server2.call(tcp_server1)
        }
        puts('1111111111111111111111111 3002')
        stop_pair_server($threads[0])
      end

      $threads[0]['next_thread'] = $threads[1]
      $threads[1]['next_thread'] = $threads[0]

      puts('End self.start')
    end

    def self.stop
      puts('STOP 1')
 #     $threads.each do |thread|
        $threads[0].raise('restart')
 #     end
      puts('STOP 2')

      sleep(1)
    end

    def self.stop_pair_server(pair_thread)
      return if pair_thread.nil?
      return until pair_thread.alive?
      pair_thread.raise('restart')
    end
  end
end