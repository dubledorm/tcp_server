class Api::ApiController < ApplicationController

  def restart
    $tcp_server_control.stop
    render json: 'Ok'
  end
end
