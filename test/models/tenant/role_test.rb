require 'test_helper'

class Tenant::RoleTest < ActiveSupport::TestCase
  setup do
    @role = FactoryGirl.create(:role, name: 'Admin')
  end

  test "should be invalid without a name" do
    role = FactoryGirl.build(:role, name: nil)

    assert !role.valid?, "Name is not being validated"
  end

  test "should be invalid with duplicate name" do
    role = FactoryGirl.build(:role, name: @role.name)

    assert !role.valid?, "Name cannot be duplicated"
  end
end
