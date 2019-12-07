# frozen_string_literal: true

module TcpServer
  # TcpServer. It reads byte from socket and sends the bytes to pair tcp_server
  class SimpleTcpServer
    def initialize(port, tcp_server_control)
      @port = port
      @status = 'Created'
      @tcp_server_control = tcp_server_control
    end

    def call(mode = :smart)
      server = TCPServer.new(@port)
      signal = :nothing
      loop do
        begin
          @socket = wait_connect(server)
          raise if @socket.nil?

          copy_stream
          stop_pair_server if mode == :dumb
        rescue Exception => e
          Rails.logger.info('Exception.class = ' + e.class.name + 'Message = ' + e.message)
          signal = :stop if e.message == 'stop'
        end

        @socket&.close
        @socket = nil
        if signal == :stop
          server_close(server)
          return
        end
      end
    end

    attr_reader :socket, :port, :status

    private

    attr_accessor :tcp_server_control

    def wait_connect(server)
      @status = 'Wait connect'
      Rails.logger.info('wait_connect ' + @port.to_s)
      socket = server.accept
      Rails.logger.info('client connected on ' + @port.to_s)
      socket
    end

    def copy_stream
      @status = 'Copy stream'
      Rails.logger.info('copy_stream' + @port.to_s)
      begin
      loop do
        one_byte = socket_read
        break if one_byte.empty?

        write_to_pair(one_byte)
      end
      rescue RuntimeError
        raise
      end
    end

    def socket_read
      one_byte = @socket.recv(16)
      if one_byte.empty?
        Rails.logger.info('client disconnected from ' + @port.to_s)
      end
      one_byte
    end

    def write_to_pair(one_byte)
      @tcp_server_control.get_pair_socket(@port)&.write(one_byte)
      Rails.logger.info("->#{one_byte}")
    end

    def server_close(server)
      @status = 'Closing'
      Rails.logger.info('closed server on port ' + port.to_s)
      server.close
      @status = 'Closed'
    end

    # Остановить парный сервер
    def stop_pair_server
      Thread.handle_interrupt(Exception => :never) do
        Thread.current.report_on_exception = false
        Rails.logger.info('stop TcpServer on port ')
        pair_thread = @tcp_server_control.get_pair_thread(@port)
        return if pair_thread.nil?

        return unless pair_thread.alive?

        pair_thread.raise('restart')
      end
    end
  end
end