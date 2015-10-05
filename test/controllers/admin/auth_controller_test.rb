require 'test_helper'

class Admin::AuthControllerTest < ActionController::TestCase
  setup do
    @landlord = FactoryGirl.create(:landlord)
  end

  test "should get login" do
    get :login
    assert_response :success
  end

  test "should authorize via post" do
    post :login, name: @landlord.name, password: @landlord.password

    assert_equal @landlord.id, session[:landlord_id], "Authentication doesn't work"
    assert_redirected_to admin_root_url
  end

  test "should get logout" do
    session[:landlord_id] = 1
    get :logout

    assert_nil session[:landlord_id], "Logout doesn't work"
    assert_redirected_to admin_login_url
  end
end
