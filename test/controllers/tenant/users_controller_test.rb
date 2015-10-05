require 'test_helper'

class Tenant::UsersControllerTest < ActionController::TestCase
  setup do
    @roles = {}
    [:admin, :manager, :reporter, :client].each do |role|
      @roles[role] = FactoryGirl.create(:role, name: role.to_s.camelize)
    end
    @current_user = FactoryGirl.build(:user, role_ids: [@roles[:admin].id])
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show user" do
    user = FactoryGirl.build(:user)
    user.invite!

    get :show, id: user
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    user = FactoryGirl.build(:user)
    user.invite!

    get :edit, id: user
    assert_response :success
  end

  test "should create user" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:manager], @roles[:client]]

    assert_difference('Tenant::User.count', 1) do
      post :create, tenant_user: { email: user.email, name: user.name, role_ids: user.role_ids }
    end

    created_user = assigns(:resource)
    assert_not_nil created_user
    assert_equal user.email, created_user.email, "Email isn't saved when user is created"
    assert_equal user.name, created_user.name, "Name isn't saved when user is created"
    assert_equal user.role_ids.sort, created_user.role_ids.sort, "Roles aren't saved when user is created"
    assert_redirected_to tenant_users_url
  end

  test "shouldn't create invalid user" do
    user = FactoryGirl.build(:user, email: '')

    assert_no_difference('Tenant::User.count') do
      post :create, tenant_user: { email: user.email, name: user.name, role_ids: user.role_ids }
    end

    assert_response :success
  end

  test "should update unconfirmed user" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:client]]
    user.invite!

    new_user = FactoryGirl.build(:user)
    new_user.roles = [@roles[:manager]]

    assert_no_difference('Tenant::User.count') do
      patch :update, id: user, tenant_user: { email: new_user.email, name: new_user.name, role_ids: new_user.role_ids }
    end

    updated_user = assigns(:resource)
    assert_not_nil updated_user
    assert updated_user.valid?, "User is invalid after update"
    assert_equal new_user.email, updated_user.email, "Email isn't saved when user is updated"
    assert_equal new_user.name, updated_user.name, "Name isn't saved when user is updated"
    assert_equal new_user.role_ids.sort, updated_user.role_ids.sort, "Roles aren't saved when user is updated"
    assert !updated_user.invitation_accepted?, "User should not be auto-invited after update"
    assert_redirected_to tenant_users_url
  end

  test "shouldn't update unconfirmed invalid user" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:client]]
    user.invite!

    new_user = FactoryGirl.build(:user, email: '')
    new_user.roles = [@roles[:manager]]

    assert_no_difference('Tenant::User.count') do
      patch :update, id: user, tenant_user: { email: new_user.email, name: new_user.name, role_ids: new_user.role_ids }
    end

    updated_user = assigns(:resource)
    assert_not_nil updated_user
    assert !updated_user.valid?, "User should be invalid"
    assert_response :success
  end

  test "should update confirmed user" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:client]]
    user.invite!
    user.accept_invitation!

    new_user = FactoryGirl.build(:user)
    new_user.roles = [@roles[:manager]]

    assert_no_difference('Tenant::User.count') do
      patch :update, id: user, tenant_user: { email: new_user.email, name: new_user.name, role_ids: new_user.role_ids }
    end

    updated_user = assigns(:resource)
    assert_not_nil updated_user
    assert updated_user.valid?, "User is invalid after update"
    assert_not_equal new_user.email, updated_user.email, "Email shouldn't be saved without confirmation"
    assert_equal new_user.name, updated_user.name, "Name isn't saved when user is updated"
    assert_equal new_user.role_ids.sort, updated_user.role_ids.sort, "Roles aren't saved when user is updated"
    assert_redirected_to tenant_users_url
  end

  test "shouldn't update confirmed invalid user" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:client]]
    user.invite!
    user.accept_invitation!

    new_user = FactoryGirl.build(:user, email: '')
    new_user.roles = [@roles[:manager]]

    patch :update, id: user, tenant_user: { email: new_user.email, name: new_user.name, role_ids: new_user.role_ids }

    updated_user = assigns(:resource)
    assert_not_nil updated_user
    assert !updated_user.valid?, "User should be invalid"
    assert_response :success
  end

  test "should destroy user" do
    user = FactoryGirl.build(:user)
    user.invite!

    assert_difference('Tenant::User.count', -1) do
      delete :destroy, id: user
    end

    assert_redirected_to tenant_users_url
  end
end
