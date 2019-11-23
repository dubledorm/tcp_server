module TcpServer
  class SimpleTcpServer
    def initialize(port)
      puts("initialize port = #{port}")
      @port = port
      puts("initialize finish port = #{port}")
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
      puts('wait_connect ' + @port.to_s)
      server.accept
    end

    def copy_stream(pair_tcp_server)
      puts('copy_stream' + @port.to_s)
      begin
      loop do
        one_byte = @socket.getc
        if one_byte.nil?
          break
        end
        pair_tcp_server.socket&.putc(one_byte)
        puts("->#{one_byte}")
      end
      rescue RuntimeError
        puts('RunTime Error')
        raise
      end
    end
  end
end