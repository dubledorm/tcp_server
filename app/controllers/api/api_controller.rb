# frozen_string_literal: true

# Controller for api functions
class Api::ApiController < ApplicationController

  @@tcp_server_controls = []

  def stop_pair
    tcp_server_control = @@tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.
        has_pair?(params.require(:port1), params.require(:port2))}.first
    if tcp_server_control.nil?
      render json: { message: 'Don`t find the pair of ports' }, status: 400
      return
    end

    tcp_server_control.stop
    @@tcp_server_controls.delete(tcp_server_control)
    render json: { message: 'Ok' }, status: 200
  end

  def start_pair
    ports = [params.require(:port1), params.require(:port2)]
    [0, 1].each do |i|
      if use_port?(ports[i])
        render json: { message: "The port number #{ports[i]} already used" }, status: 400
        return
      end
    end

    tcp_server_control = TcpServer::TcpServerControl.new(ports)
    tcp_server_control.start
    @@tcp_server_controls << tcp_server_control
    render json: { message: 'Ok' }, status: 200
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

    render json: response, status: 200
  end

  private

    def use_port?(port)
      @@tcp_server_controls.find_all{ |tcp_server_control| tcp_server_control.has_port?(port) }.size != 0
    end
end
