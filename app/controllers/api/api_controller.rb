# frozen_string_literal: true

# Controller for api functions
class Api::ApiController < ApplicationController
  include ServerControlTools

  def stop_pair
    tcp_server_control = find_pair(params.require(:port1), params.require(:port2))

    raise ActionController::BadRequest.new('Don`t find the pair of ports') if tcp_server_control.nil?

    tcp_server_control.stop
    $tcp_server_controls.delete(tcp_server_control)
    render json: { message: 'Ok' }, status: 200
  end

  def start_pair
    ports = [params.require(:port1), params.require(:port2)]
    port = find_used_port(ports)
    raise ActionController::BadRequest.new("The port number #{port} already used") unless port.nil?

    start_tcp_server(ports, :smart)
    render json: { message: 'Ok' }, status: 200
  end

  def health_check
    response = { status: 'Ok',
                 message: '',
                 threads_qu: Thread.list.count,
                 tcp_server_controls_qu: $tcp_server_controls.count,
                 pairs: [] }

    $tcp_server_controls.each do |tcp_server_control|
      response[:pairs] << tcp_server_control.status
    end

    render json: response, status: 200
  end
end
