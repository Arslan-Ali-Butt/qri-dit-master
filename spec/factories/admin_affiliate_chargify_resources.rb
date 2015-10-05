# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_affiliate_chargify_resource, :class => 'Admin::AffiliateChargifyResource' do
    base_component_id "MyString"
    qrids_component_id "MyString"
    tenant nil
  end
end
