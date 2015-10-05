# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :qrid, class: 'Tenant::Qrid' do
    association :site, factory: :site
    sequence(:name) { |n| "#{Faker::Venue.name} QRID - #{n}" }
    estimated_duration '1.00'
    association :work_type, factory: :work_type
  end
end
