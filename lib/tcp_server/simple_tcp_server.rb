module TcpServer
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
          @socket&.close
          server.close
        end
      rescue
        @socket&.close
        server.close
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
        one_byte = @socket.getc
        if one_byte.nil?
          Rails.logger.info('client disconnected from ' + @port.to_s)
          break
        end
        pair_tcp_server.socket&.putc(one_byte)
        Rails.logger.info("->#{one_byte}")
      end
      rescue RuntimeError
        raise
      end
    end
  end
end