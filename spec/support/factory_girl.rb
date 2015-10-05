# spec/support/factory_girl.rb
require 'ffaker'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end