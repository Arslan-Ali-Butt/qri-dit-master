# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :permatask, class: 'Tenant::Permatask' do
    name 'Please add a photo'
    task_type 'Photo'
  end
end
