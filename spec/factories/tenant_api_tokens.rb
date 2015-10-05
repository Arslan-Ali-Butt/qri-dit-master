# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tenant_api_token, :class => 'Tenant::ApiToken' do
    token { SecureRandom.hex }
    association :user, factory: :user
  end
end
