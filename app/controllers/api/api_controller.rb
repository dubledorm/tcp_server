class Api::ApiController < ApplicationController

  def restart
    TcpServer::TcpServerControl.stop
    render json: 'Ok'
  end
end
