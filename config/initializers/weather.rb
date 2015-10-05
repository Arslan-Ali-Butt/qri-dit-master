opt = {}
config_file = File.join(Rails.root, 'config', 'weather.yml')
YAML.load(File.open(config_file)).each do |key, value|
  opt[key.to_sym] = value
end if File.exists?(config_file)

Rails.configuration.forecast_io = opt