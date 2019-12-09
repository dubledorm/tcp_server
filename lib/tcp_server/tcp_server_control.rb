# frozen_string_literal: true

module TcpServer
  # TcpServerControl. Class for start and stop the pair of SimpleTcpServers
  class TcpServerControl
    def initialize(ports, mode, debug)
      @threads = []
      @tcp_servers = [nil, nil] # инициализируем, чтобы не делать проверок в get_pair_socket
      @ports = ports
      @mode = mode.to_sym
      @debug = debug
    end

    def start
      Thread.new do
        Rails.application.executor.wrap do
          start_pair(@ports)
          sleep(1) while pair_alive?
        end
      end
    end

    def stop
      @threads.each do |thread|
        thread.raise('stop')
      end
      sleep(1) while pair_alive?
    end

    def status
      result = { mode: mode,
                 threads: [] }
      @tcp_servers.each do |tcp_server|
        result[:threads] << { port: tcp_server.port,
                              status: tcp_server.status }
      end
      result
    end

    # Для переданного порта находит пару у связанного с ним сервера
    def get_pair_socket(port)
      [0, 1].each do |number|
        if @ports[number] != port
          return nil if @tcp_servers[number].nil?
          return @tcp_servers[number].socket
        end
      end
      nil
    end

    def get_pair_thread(port)
      [0, 1].each do |number|
        if @ports[number] != port
          return @threads[number]
        end
      end
      nil
    end

    def has_pair?(port1, port2)
      ports.include?(port1) && ports.include?(port2)
    end

    def has_port?(port)
      ports.include?(port)
    end

    attr_accessor :ports

    private

    attr_accessor :mode, :debug

    def start_pair(ports)
      @ports = ports
      [0, 1].each do |number|
        @tcp_servers[number] = TcpServer::SimpleTcpServer.new(@ports[number], self, debug)
      end

      [0, 1].each do |number|
        @threads[number] = Thread.new do
          execute(number)
        end
      end
    end

    def pair_alive?
      @threads[0]&.alive? || @threads[1]&.alive?
    end

    def execute(number)
      Thread.handle_interrupt(Exception => :immediate) do
        @tcp_servers[number].call(mode)
      end
    end
  end
end