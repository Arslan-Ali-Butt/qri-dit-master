# # Read about factories at https://github.com/thoughtbot/factory_girl

# FactoryGirl.define do
#   factory :tenant, class: 'Admin::Tenant' do
#     priceplan_id { Admin::Priceplan.pluck(:id).sample }
#     subdomain { Faker::Internet.domain_word[0, 18] }
#     company_name { Faker::Company.name }
#     company_website { Faker::Internet.http_url }
#     name { Faker::Name.name }
#     phone { Faker::PhoneNumber.phone_number }
#     phone_ext { Faker::String.from_regexp /\d*/ }
#     admin_email { Faker::Internet.email }
#     host_url { Faker::Internet.domain_name }
#     card_holder { Faker::Name.name }
#     card_number { %w[4242424242424242 5555555555554444 378282246310005].sample  }
#     card_code { %w[128 256 512].sample }
#     card_exp_month { Random.new.rand(1..12) }
#     card_exp_year { Random.new.rand(2015..2020) }
#     address_line1 { Faker::AddressCA.street_address }
#     address_city { Faker::AddressCA.city }
#     address_county { Faker::AddressCA.province }
#     address_country { 'Canada' }
#     address_postal { Faker::AddressCA.postal_code }
#     payment_recurrence { [1,2].sample }
#   end
# end