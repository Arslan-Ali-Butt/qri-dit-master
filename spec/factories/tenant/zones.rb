# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zone, class: 'Tenant::Zone' do
    sequence(:name) { |n| "#{Faker::AddressCA.neighborhood} - #{n}" }
  end
end
