# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tenant_note, class: 'Admin::TenantNote' do
    association :author, factory: :landlord
    association :tenant, factory: :tenant
    title 'A title'
    note 'A note'
  end
end
