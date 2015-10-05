require 'test_helper'

class Tenant::UserTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  test "should be invalid without a name" do
    user = FactoryGirl.build(:user, name: nil)

    assert !user.valid?, "Name is not being validated"
  end

  test "should be invalid without an email" do
    user = FactoryGirl.build(:user, email: nil)

    assert !user.valid?, "Email is not being validated"
  end

  test "should not be granted as admin by default" do
    user = FactoryGirl.build(:user)

    assert !user.role?(:admin), "User is granted with admin privileges by default"
  end

  test "should be able to act as admin" do
    role = FactoryGirl.create(:role, name: 'Admin')
    @user.roles << role

    assert @user.role?(:admin), "User cannot be granted with admin privileges"
  end
end
