require 'test_helper'

class Tenant::SiteTest < ActiveSupport::TestCase
  setup do
    @site = FactoryGirl.create(:site)
  end

  test "should be invalid without a name" do
    site = FactoryGirl.build(:site, name: nil)

    assert !site.valid?, "Name is not being validated"
  end

  test "should be invalid with duplicate name" do
    site = FactoryGirl.build(:site, name: @site.name)

    assert !site.valid?, "Name cannot be duplicated"
  end

  test "should be invalid without a client" do
    site = FactoryGirl.build(:site, owner_id: nil)

    assert !site.valid?, "Client is not being validated"
  end
end
