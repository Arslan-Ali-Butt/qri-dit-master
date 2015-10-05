# opt = {}
# config_file = File.join(Rails.root, 'config', 'chargebee.yml')
# YAML.load(File.open(config_file)).each do |key, value|
#   opt[key.to_sym] = value
# end if File.exists?(config_file)

# Rails.configuration.chargebee = opt
ChargeBee.configure(api_key: ENV['CHARGEBEE_API_KEY'], site: ENV['CHARGEBEE_SITE'])