require 'test_helper'

class Admin::TenantTest < ActiveSupport::TestCase
  test "should be invalid without a company name" do
    tenant = FactoryGirl.build(:tenant, name: nil)

    assert !tenant.valid?, "Company Name is not being validated"
  end

  test "should be invalid without a subdomain" do
    tenant = FactoryGirl.build(:tenant, subdomain: nil)

    assert !tenant.valid?, "Subdomain is not being validated"
  end

  test "should be invalid with duplicate subdomain" do
    curr_tenant = FactoryGirl.create(:tenant)
    tenant = FactoryGirl.build(:tenant, subdomain: curr_tenant.subdomain)

    assert !tenant.valid?, "Subdomain cannot be duplicated"
  end

  test "should be invalid with subdomain of incorrect format" do
    tenant = FactoryGirl.build(:tenant, subdomain: 'Abcde')
    assert !tenant.valid?, "Subdomain cannot contain UPPERCASE letters"

    tenant = FactoryGirl.build(:tenant, subdomain: 'a b c')
    assert !tenant.valid?, "Subdomain cannot contain spaces"

    tenant = FactoryGirl.build(:tenant, subdomain: 'abc_de')
    assert !tenant.valid?, "Subdomain cannot contain special characters"
  end

  test "should be invalid with a duplicate subdomain" do
    curr_tenant = FactoryGirl.create(:tenant)
    tenant = FactoryGirl.build(:tenant, subdomain: curr_tenant.subdomain)

    assert !tenant.valid?, "Subdomain uniqueness is not being validated"
  end

  test "should be invalid without admin email" do
    tenant = FactoryGirl.build(:tenant, admin_email: nil)

    assert !tenant.valid?, "Admin email is not being validated"
  end

  test "should switch back database after creating new tenant" do
    tenant = FactoryGirl.create(:tenant)
    db_name = Apartment::Tenant.current_tenant

    assert_equal 'public', db_name, "Database is not switched back after tenant is created"
  end

  test "should seed database after creating new tenant" do
    tenant = FactoryGirl.create(:tenant)
    db_name = Apartment::Tenant.switch("tenant#{tenant.id}")

    role = Tenant::Role.find_by(name: 'Admin')

    assert_not_nil role, "Database haven't been seed after tenant registration"
  end

  test "should create initial admin user after creating new tenant" do
    tenant = FactoryGirl.create(:tenant)
    db_name = Apartment::Tenant.switch("tenant#{tenant.id}")

    user = Tenant::User.find_by(email: tenant.admin_email)

    assert_not_nil user, "Initial user is not created after tenant registration"
    assert user.role?(:admin), "Initial tenant user is not granted with admin right"
  end
end
