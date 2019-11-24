# frozen_string_literal: true

module TcpServer
  # TcpServerControl. Class for start and stop the pair of SimpleTcpServers
  class TcpServerControl
    def initialize
      @threads = []
      @tcp_servers = []
    end

    def start(ports)
      @ports = ports
      [0, 1].each do |number|
        @tcp_servers[number] = TcpServer::SimpleTcpServer.new(@ports[number])
      end

      [0, 1].each do |number|
        @threads[number] = Thread.new do
          execute(number)
          stop_pair_server(number)
        end
      end
    end

    def stop
      @threads.each do |thread|
        thread.raise('restart')
      end
      sleep(1)
    end

    def pair_alive?
      @threads[0].alive? || @threads[1].alive?
    end

    private

    def stop_pair_server(number)
      Thread.handle_interrupt(Exception => :never) do
        Thread.current.report_on_exception = false
        Rails.logger.info('stop TcpServer on port ' + @ports[number].to_s)
        pair_thread = @threads[number.zero? ? 1 : 0]
        return if pair_thread.nil?

        return unless pair_thread.alive?

        pair_thread.raise('restart')
      end
    end

    def execute(number)
      Thread.handle_interrupt(Exception => :immediate) do
        @tcp_servers[number].call(@tcp_servers[number.zero? ? 1 : 0])
      end
    end
  end
end