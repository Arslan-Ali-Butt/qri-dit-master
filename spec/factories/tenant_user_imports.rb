# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tenant_user_import, :class => 'Tenant::UserImport' do
    user_import_file "MyString"
    num_users 1
    status 1
    error_messages "MyString"
    type ""
  end
end
