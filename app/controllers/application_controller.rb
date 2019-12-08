class ApplicationController < ActionController::API

  rescue_from ActionController::ParameterMissing, :with => :bad_request unless Rails.env.development?
  rescue_from ActionController::BadRequest, :with => :bad_request unless Rails.env.development?

  def bad_request(e)
    render json: { message: e.message }, status: 400
  end
end
