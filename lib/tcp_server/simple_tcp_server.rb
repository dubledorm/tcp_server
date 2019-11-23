module TcpServer
  class SimpleTcpServer
    def initialize(port)
      puts("initialize port = #{port}")
      @port = port
      Thread.current['stop_flag'] = false
      puts("initialize finish port = #{port}")
    end

    def call
      server = TCPServer.new(port)
      begin
        loop do
          Thread.current['socket'] = wait_connect(server)
          next if Thread.current['socket'].nil?

          copy_stream(Thread.current['socket'])
          Thread.current['socket']&.close
          server.close
        end
      rescue
        Thread.current['socket']&.close
        server.close
      end
    end

    private

    attr_accessor :port

    def wait_connect(server)
      puts('wait_connect ' + @port.to_s)
      server.accept
    end

    def copy_stream(socket)
      puts('copy_stream' + @port.to_s)
      # while Thread.current['next_thread']['socket'].nil? && !socket.closed?
      #   puts('wait for next_thread' + @port.to_s)
      #   sleep(1)
      # end
      begin
      loop do
        one_byte = socket.getc
        if one_byte.nil?
 #         Thread.current['next_thread']['socket'].close
          break
        end
        Thread.current['next_thread']['socket'].putc(one_byte) unless Thread.current['next_thread']['socket'].nil?
        puts("->#{one_byte}")
      end
      rescue RuntimeError
        puts('RunTime Error')
        raise
      end
    end
  end
end