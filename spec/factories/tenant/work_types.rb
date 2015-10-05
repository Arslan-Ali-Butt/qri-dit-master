# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :work_type, class: 'Tenant::WorkType' do
    sequence(:name) { |n| "Work type - #{n}" }
  end
end
