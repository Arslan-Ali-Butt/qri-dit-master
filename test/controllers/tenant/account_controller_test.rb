require 'test_helper'

class Tenant::AccountControllerTest < ActionController::TestCase
  setup do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test "should show account to authorized" do
    @client_role = FactoryGirl.create(:role, name: 'Client')
    @current_user = FactoryGirl.build(:user, role_ids: [@client_role.id])
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user

    get :show
    assert_response :success
  end

  test "should redirect if unauthorized" do
    get :show
    assert_redirected_to new_user_session_url
  end
end
