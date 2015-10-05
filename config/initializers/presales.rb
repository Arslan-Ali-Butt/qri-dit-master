config_file = File.join(Rails.root, 'config', 'presales.yml')
Rails.configuration.presales = YAML.load(File.open(config_file)) if File.readable?(config_file)