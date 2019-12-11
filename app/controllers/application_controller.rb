class ApplicationController < ActionController::API

  rescue_from ActionController::ParameterMissing, :with => :bad_request unless Rails.env.development?
  rescue_from ActionController::BadRequest, :with => :bad_request unless Rails.env.development?
  rescue_from Redis::CannotConnectError, :with => :redis_connection_error

  def bad_request(e)
    render json: { message: e.message }, status: 400
  end

  def redis_connection_error(e)
    Rails.logger.error("Redis error: #{e.message}")
    exit(-1)
  end
end
