# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site, class: 'Tenant::Site' do
    association :owner, factory: :client
    association :address, factory: :address
    sequence(:name) { |n| "#{Faker::Venue.name} #{n}" }
    association :zone, factory: :zone
    alarm_code { Faker::Lorem.word }
    alarm_safeword { Faker::Name.name }
    alarm_company { Faker::Company.name }
    emergency_number { Faker::PhoneNumber.phone_number }
  end
end
