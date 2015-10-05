# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :landlord, class: 'Admin::Landlord' do
    sequence(:name) { |n| "#{Faker::Internet.user_name[0, 15]} #{n}" }
    password { Faker::String.from_regexp /\w+\w+\w+\w+\w+\w+\w+/ }
    password_confirmation { "#{password}" }
  end
end
