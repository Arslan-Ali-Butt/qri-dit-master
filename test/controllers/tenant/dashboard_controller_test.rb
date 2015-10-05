require 'test_helper'

class Tenant::DashboardControllerTest < ActionController::TestCase
  setup do
    @current_user = FactoryGirl.build(:user)
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user
  end

  test "should get index" do
    get :index
    assert_response :success
  end
end
