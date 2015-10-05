# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report, class: 'Tenant::Report' do
    association :assignment, factory: :assignment, status: 'Done'
    started_at { Time.now }
  end
end
