require 'redis'
require 'server_control_tools'

module Monitoring
  class RedisLogger < Monitoring::Base
    protected
      def write_to_channel(port, message)
        begin
          channel_name = find_channel(port)
          $redis.publish channel_name, message unless channel_name.nil?
        rescue Redis::CannotConnectError => e
          Rails.logger.error("Redis error: #{e.message}")
        end
      end

    private

      def find_channel(port)
        tcp_server_control = find_pair_by_port(port)
        tcp_server_control&.ports&.join('_')
      end
  end
end