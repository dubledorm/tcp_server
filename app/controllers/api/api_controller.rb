# frozen_string_literal: true

# Controller for api functions
class Api::ApiController < ApplicationController
  def restart
    $tcp_server_control.stop
    render json: { message: 'Ok' }
  end

  def health_check
    response = { status: 'Ok',
                 message: '',
                 thread_qu: Thread.list.count,
                 threads: [] }

    response[:threads] << $tcp_server_control.status

    render json: response
  end
end
