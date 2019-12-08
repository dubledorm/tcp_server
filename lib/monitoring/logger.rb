module Monitoring
  class Logger < Monitoring::Base

  protected
    def write_to_channel(message)
      Rails.logger.info(message)
    end
  end
end