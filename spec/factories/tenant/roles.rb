# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role, class: 'Tenant::Role' do
    sequence(:name) { |n| "Role - #{n}" }
  end
end
