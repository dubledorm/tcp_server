# frozen_string_literal: true

# Controller for api functions
class Test::ApiController < ApplicationController
  def test_health_check
    number_of_hours = params['api']['number_of_hours']
    render json: { number_of_null_ti: number_of_hours }
  end
end
