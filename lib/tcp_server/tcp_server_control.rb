# frozen_string_literal: true

module TcpServer
  # TcpServerControl. Class for start and stop the pair of SimpleTcpServers
  class TcpServerControl
    def initialize(ports)
      @threads = []
      @tcp_servers = [nil, nil] # инициализируем, чтобы не делать проверок в get_pair_socket
      @ports = ports
    end

    def start
      Thread.new do
        loop do
          start_pair(@ports)
          sleep(1) while pair_alive?
        end
      end
    end

    def stop
      @threads.each do |thread|
        thread.raise('restart')
      end
      sleep(1)
    end

    def status
      result = []
      @tcp_servers.each do |tcp_server|
        result << { port: tcp_server.port,
                    status: tcp_server.status }
      end
      result
    end

    def get_pair_socket(port)
      [0, 1].each do |number|
        if @ports[number] != port
          return nil if @tcp_servers[number].nil?
          return @tcp_servers[number].socket
        end
      end
      nil
    end

    private

    attr_accessor :ports

    def start_pair(ports)
      @ports = ports
      [0, 1].each do |number|
        @tcp_servers[number] = TcpServer::SimpleTcpServer.new(@ports[number], self)
      end

      [0, 1].each do |number|
        @threads[number] = Thread.new do
          execute(number)
 #         stop_pair_server(number)
        end
      end
    end

    # Остановить парный сервер
    # def stop_pair_server(number)
    #   Thread.handle_interrupt(Exception => :never) do
    #     Thread.current.report_on_exception = false
    #     Rails.logger.info('stop TcpServer on port ' + @ports[number].to_s)
    #     pair_thread = @threads[number.zero? ? 1 : 0]
    #     return if pair_thread.nil?
    #
    #     return unless pair_thread.alive?
    #
    #     pair_thread.raise('restart')
    #   end
    # end

    def pair_alive?
      @threads[0].alive? || @threads[1].alive?
    end

    def execute(number)
      Thread.handle_interrupt(Exception => :immediate) do
        @tcp_servers[number].call
      end
    end
  end
end