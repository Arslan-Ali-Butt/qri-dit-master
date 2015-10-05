Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.development_environments = ['development', 'test', 'cucumber', 'local_production']
end
