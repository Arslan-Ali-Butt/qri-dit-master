# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment, class: 'Tenant::Assignment' do
    association :assignee, factory: :staff
    association :qrid, factory: :qrid
    start_at { Time.now }
    end_at { Time.now + 1.hour }

    trait :daily do
      recurrence 'd'
    end

    trait :weekly do
      recurrence 'w'
    end

    trait :fortnightly do
      recurrence '2w'
    end

    trait :monthly do
      recurrence 'm'
    end

    trait :yearly do
      recurrence 'y'
    end
  end
end
