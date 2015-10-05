# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include AuthHelpers, :type => :request

  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller

  config.include Warden::Test::Helpers


  config.include JsonSpec::Helpers

  Warden.test_mode!

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end

    # Clean all tables to start
    DatabaseCleaner.clean_with :truncation
    # Use transactions for tests
    DatabaseCleaner.strategy = :transaction

    Apartment::Tenant.drop('tenant1') rescue nil
    Apartment::Tenant.drop('tenant2') rescue nil

    # Create the default tenant for our tests

    Admin::Tenant.create!(subdomain: 'test1', company_name: 'ABC Inc.', name: 'John Doe', 
      phone: '555-4141', admin_email: 'jdoe@abc.com', timezone: 'Eastern Time (US & Canada)', 
      priceplan_id: 3, country_code: 'CA', billing_recurrence: 0, host_url: 'test1.example.com')

    Admin::Tenant.create!(subdomain: 'test2', company_name: 'XYZ Inc.', name: 'James Doe', 
      phone: '555-5151', admin_email: 'jdoe@xyz.com', timezone: 'Eastern Time (US & Canada)', 
      priceplan_id: 3, country_code: 'CA', billing_recurrence: 0, host_url: 'test2.example.com')
  end

  config.before(:each) do
    # Start transaction for this test
    DatabaseCleaner.start
    # Switch into the default tenant
    tenant = Admin::Tenant.find_by(subdomain: 'test1')

    Apartment::Tenant.switch "tenant#{tenant.id}"
  end

  config.after(:each) do
    # Reset tentant back to `public`
    Apartment::Tenant.reset
    # Rollback transaction
    DatabaseCleaner.clean

    Warden.test_reset!
  end
end
