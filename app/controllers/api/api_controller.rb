# frozen_string_literal: true

# Controller for api functions
class Api::ApiController < ApplicationController

  @@tcp_server_controls = []

  def restart
  #  $tcp_server_control.stop
    render json: { message: 'Ok' }
  end

  def start_pair
    ports = [params.require(:port1), params.require(:port2)]
    tcp_server_control = TcpServer::TcpServerControl.new(ports)
    tcp_server_control.start
    @@tcp_server_controls << tcp_server_control
  end

  def health_check
    response = { status: 'Ok',
                 message: '',
                 threads_qu: Thread.list.count,
                 tcp_server_controls_qu: @@tcp_server_controls.count,
                 threads: [] }

    @@tcp_server_controls.each do |tcp_server_control|
      response[:threads] << tcp_server_control.status
    end

    render json: response
  end
end
