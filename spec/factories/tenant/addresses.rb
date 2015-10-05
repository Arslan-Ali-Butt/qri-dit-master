# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :address, class: 'Tenant::Address' do
    house_number { Faker::AddressCA.building_number }
    street_name { Faker::AddressCA.street_name }
    line_2 { Faker::AddressCA.neighborhood }
    city { Faker::AddressCA.city }
    province { Faker::AddressCA.province }
    postal_code { Faker::AddressCA.postal_code }
    country { Faker::AddressCA.country }
  end
end
