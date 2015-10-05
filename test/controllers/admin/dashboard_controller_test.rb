require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  setup do
    Admin::DashboardController.any_instance.stubs(:authorize).returns(true)
  end

  test "should get index" do
    get :index
    assert_response :success
  end
end
