require File.expand_path('../boot', __FILE__)

require 'rails/all'
# require 'apartment/elevators/generic'
require 'pdfkit'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module QRIDit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.

    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.i18n.enforce_available_locales = true

    config.autoload_paths += %W(#{Rails.root}/lib/)
    config.eager_load_paths += %W(#{Rails.root}/lib) if Rails.env.development?

    # Subdomain routing for Apartment (getting database schema name for tenant)
    # config.middleware.use Apartment::Elevators::Generic, Proc.new { |request|
    #   if /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/.match(request.host)
    #     nil
    #   else
    #     tenant = Admin::Tenant.cached_find_by_host(request.host)
    #     tenant ? "tenant#{tenant.id}" : nil
    #   end
    # }

    # PDF generation
    config.middleware.use PDFKit::Middleware

    config.exceptions_app = self.routes

    GC::Profiler.enable
  end
end
