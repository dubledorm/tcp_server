# frozen_string_literal: true

module TcpServer
  # TcpServer. It reads byte from socket and sends the bytes to pair tcp_server
  class SimpleTcpServer
    def initialize(port)
      @port = port
    end

    def call(pair_tcp_server)
      server = TCPServer.new(port)
      begin
        loop do
          @socket = wait_connect(server)
          next if @socket.nil?

          copy_stream(pair_tcp_server)
          all_close(server)
        end
      rescue
        all_close(server)
      end
    end

    attr_accessor :socket

    private

    attr_accessor :port

    def wait_connect(server)
      Rails.logger.info('wait_connect ' + @port.to_s)
      socket = server.accept
      Rails.logger.info('client connected on ' + @port.to_s)
      socket
    end

    def copy_stream(pair_tcp_server)
      Rails.logger.info('copy_stream' + @port.to_s)
      begin
      loop do
        one_byte = socket_read
        break if one_byte.nil?

        socket_write(pair_tcp_server, one_byte)
      end
      rescue RuntimeError
        raise
      end
    end

    def socket_read
      one_byte = @socket.getc
      if one_byte.nil?
        Rails.logger.info('client disconnected from ' + @port.to_s)
      end
      one_byte
    end

    def socket_write(pair_tcp_server, one_byte)
      pair_tcp_server.socket&.putc(one_byte)
      Rails.logger.info("->#{one_byte}")
    end

    def all_close(server)
      @socket&.close
      server.close
    end
  end
end