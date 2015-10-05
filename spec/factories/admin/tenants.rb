# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tenant, class: 'Admin::Tenant' do
    subdomain { Faker::Internet.domain_word[0, 18] }
    company_name { Faker::Company.name }
    # #company_website { Faker::Internet.http_url }
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    # #phone_ext { Faker::String.from_regexp /\d*/ }
    admin_email { Faker::Internet.email }
    host_url { Faker::Internet.domain_name }
    billing_recurrence 0
    timezone 'Eastern Time (US & Canada)'
    priceplan_id 3
    country_code 'CA'
  end
end