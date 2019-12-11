require_relative 'boot'

# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TcpServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.autoload_paths += %W(#{config.root}/lib)

    config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}, #{severity}: #{msg}\n"
    end

    config.after_initialize do
      redis_init
      init_by_env_variable
    end
  end
end
