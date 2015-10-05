source 'https://rubygems.org'
ruby '2.0.0'
gem 'rails', '~> 4.0.0'

# Data handling
gem 'pg'
gem 'apartment'                   # Multitenancy
gem 'mysql2'
gem 'thinking-sphinx', '~> 3.1.1'             # Search engine
gem 'strip_attributes'            # Strip attributes before validation
gem 'carmen-rails'                # Countries and provinces
gem 'acts_as_ordered_tree', '~> 2.0.0.beta3'
gem 'ice_cube', '~> 0.12.1'                   # Recurring events

# Payment processing
gem 'rest-client'
gem 'multi_json'
gem 'stripe'
gem 'chargebee'
gem 'chargify_api_ares'


# File uploader
gem 'paperclip'                   # File uploading
gem 'remotipart'                  # File uploading via AJAX

# AWS SDK gem
gem 'aws-sdk'

# Authentication & authorization
gem 'devise'
gem 'devise-async'
gem 'devise_invitable'
gem 'cancan'

# Background job processor
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'apartment-sidekiq'
#gem 'ts-sidekiq-delta', '~> 0.2.0' # background index processor for Thinking Sphinx

# Data representation
gem 'rqrcode-with-patches'        # QR codes generator
gem 'pdfkit'                      # PDF generator
gem 'roo'
gem 'jbuilder'

# Assets management
gem 'haml-rails', '>= 0.4'
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 2.3.0'
gem 'therubyracer', platforms: :ruby, require: 'v8'

# Client side
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'jquery-fileupload-rails'

gem 'turbolinks'
gem 'jquery-turbolinks'

gem 'bootstrap-sass'
gem 'font-awesome-rails'          # Font-awesome wrapper
gem 'fullcalendar-rails'          # Fullcalendar wrapper
gem 'momentjs-rails'              # Moment.js wrapper
gem 'selectize-rails'             # Selectize.js wrapper
gem 'touchpunch-rails'            # Touch Event Support for jQuery UI
gem 'autosize-rails'              # Automatically adjust textarea height
#gem 'bootstrap-slider-rails', github: 'stationkeeping/bootstrap-slider-rails'

gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'

gem 'will_paginate' # for server side pagination

gem 'geocoder' # server side geocoding

# Cron jobs
gem 'whenever', require: false

# Social Media
gem 'twitter'

# user agent
gem 'useragent', github: 'josh/useragent'

gem 'versionist' # gem for managing Rails APIs

gem 'paper_trail', '~> 3.0.6' # to track changes to models (important for the API)
gem 'paranoia', '~> 2.0.2'  # so we don't have to deal with the headache of hard deletes in some cases
gem 'activerecord-import' # inter tenant data transfers

group :development, :test do
  gem "factory_girl_rails", "~> 4.0"   # test data factories
  gem 'rspec-rails', '~> 3.0.0'   # we like Rspec!
  gem "database_cleaner"          # a gem that will let us test using Apartment
  gem "json_spec"                 # a gem to allow us to easily test JSON responses in Rspec
  gem 'codeclimate_ci'            # api for CodeClimate
end

group :test do
  gem 'mocha', require: false     # method stubs and mocks
end
gem 'ffaker'                      # random data generator

group :development do
  gem 'thin'                      # web-server for development
  gem 'capistrano'                # deploy
  gem 'capistrano-rvm'
  gem 'capistrano-rails'

  # gem 'mailcatcher' # Disabling mailcatcher because of conflict with other gems
end

# Monitoring
gem 'airbrake'

# Configuration management
gem "rails_config"

gem 'newrelic_rpm'

# native app gems
gem 'zero_push'

group :production,:staging do
  #gem 'unicorn', platform: :ruby
  gem 'puma'
  gem 'dalli'
  gem 'flying-sphinx'
  gem 'rails_12factor'
end
gem "rack-timeout"
