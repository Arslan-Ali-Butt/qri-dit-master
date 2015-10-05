require 'test_helper'

class Admin::LandlordTest < ActiveSupport::TestCase
  setup do
    @landlord = FactoryGirl.create(:landlord)
  end

  test "should be invalid without a name" do
    landlord = FactoryGirl.build(:landlord, name: nil)

    assert !landlord.valid?, "Name is not being validated"
  end

  test "should be invalid without a password" do
    landlord = FactoryGirl.build(:landlord, password: nil)

    assert !landlord.valid?, "Password is not being validated"
  end

  test "should authenticate" do
    new_landlord = Admin::Landlord.authenticate(@landlord.name, @landlord.password)

    assert_equal @landlord.id, new_landlord.id, "Authentication doesn't work"
  end

  test "should not authenticate with incorrect credentials" do
    new_landlord = Admin::Landlord.authenticate(@landlord.name, '123123')

    assert_nil new_landlord, "Authentication doesn't work"
  end

  test "should save last login time on authentication" do
    now = Time.current
    new_landlord = Admin::Landlord.authenticate(@landlord.name, @landlord.password)

    assert_equal now.to_i, new_landlord.last_login_at.to_i, "Authentication doesn't save login time"
  end

  test "should not destroy last landlord" do
    assert_no_difference('Admin::Landlord.count', "Last user should not be destroyed") do
      assert_raises RuntimeError do
        @landlord.destroy
      end
    end
  end
end
