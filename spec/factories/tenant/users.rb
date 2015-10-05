# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, class: 'Tenant::User' do
    email { Faker::Internet.email }
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    password { Faker::String.from_regexp /\w+\w+\w+\w+\w+\w+\w+/ }
    password_confirmation { "#{password}" }

    after(:build)  { |user| user.roles << create(:role) }  

    factory :client, class: 'Tenant::Client' do
      client_type 'Residential'
      association :address, factory: :address
      after(:build)  { |user| user.roles << Tenant::Role.find_or_create_by(name: 'Client') }  
    end

    factory :staff, class: 'Tenant::Staff' do; end

    factory :admin, class: 'Tenant::Staff' do
      after(:build)  { |user| user.roles << Tenant::Role.find_or_create_by(name: 'Admin') }  
    end

    factory :manager, class: 'Tenant::Staff' do
      after(:build)  { |user| user.roles << Tenant::Role.find_or_create_by(name: 'Manager') }  
    end

    factory :reporter, class: 'Tenant::Staff' do
      after(:build)  { |user| user.roles << Tenant::Role.find_or_create_by(name: 'Reporter') }  
    end


  end
end
