require 'test_helper'

class Tenant::ClientsControllerTest < ActionController::TestCase
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

  test "should show client" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:client]]
    user.invite!

    get :show, id: user
    assert_response :success
  end

  test "shouldn't show reporter" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:reporter]]
    user.invite!

    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, id: user
    end
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:reporter], @roles[:client]]
    user.invite!

    get :edit, id: user
    assert_response :success
  end

  test "shouldn't get edit manager" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:manager]]
    user.invite!

    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: user
    end
  end

  test "should create client" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:manager], @roles[:client]]

    assert_difference('Tenant::User.count', 1) do
      post :create, tenant_user: { email: user.email, name: user.name, role_ids: user.role_ids }
    end

    created_user = assigns(:resource)
    assert_not_nil created_user
    assert_equal [@roles[:client].id], created_user.role_ids.sort, "Roles aren't assigned properly when client is created"
    assert_redirected_to tenant_clients_url
  end

  test "should update client" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:admin], @roles[:client]]
    user.invite!
    user.accept_invitation!

    new_user = FactoryGirl.build(:user)
    new_user.roles = [@roles[:manager]]

    patch :update, id: user, tenant_user: { email: new_user.email, name: new_user.name, role_ids: new_user.role_ids }

    updated_user = assigns(:resource)
    assert_not_nil updated_user
    assert updated_user.valid?, "Client is invalid after update"
    assert_equal user.role_ids.sort, updated_user.role_ids.sort, "Roles shouldn't change when client is updated"
    assert_equal new_user.name, updated_user.name, "Name isn't saved when client is updated"
    assert_redirected_to tenant_clients_url
  end

  test "should destroy client" do
    user = FactoryGirl.build(:user)
    user.roles = [@roles[:manager], @roles[:client]]
    user.invite!

    assert_difference('Tenant::User.count', -1) do
      delete :destroy, id: user
    end

    assert_redirected_to tenant_clients_url
  end
end
