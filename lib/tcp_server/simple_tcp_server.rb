# frozen_string_literal: true

module TcpServer
  # TcpServer. It reads byte from socket and sends the bytes to pair tcp_server
  class SimpleTcpServer
    def initialize(port, tcp_server_control)
      @port = port
      @status = 'Created'
      @tcp_server_control = tcp_server_control
    end

    def call
      server = TCPServer.new(port)
      begin
        loop do
          @socket = wait_connect(server)
          next if @socket.nil?

          copy_stream
          @socket&.close
        end
      rescue
        all_close(server)
        server.close
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

    def all_close(server)
      @status = 'Closing'
      @socket&.close
      server.close
      @status = 'Closed'
    end
  end
end