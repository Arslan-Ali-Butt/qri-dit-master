require 'test_helper'

class Admin::TenantsControllerTest < ActionController::TestCase
  setup do
    @request.host = "admin.#{@request.host}"

    Admin::TenantsController.any_instance.stubs(:authorize).returns(true)
    @tenant = FactoryGirl.create(:tenant)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tenant
    assert_response :success
  end

  test "should create tenant" do
    tenant = FactoryGirl.build(:tenant)
    assert_difference('Admin::Tenant.count', 1) do
      post :create, admin_tenant: { admin_email: tenant.admin_email, company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, subdomain: tenant.subdomain }
    end

    assert_redirected_to admin_tenants_url
  end

  test "should update tenant" do
    tenant = FactoryGirl.build(:tenant)
    patch :update, id: @tenant, admin_tenant: { admin_email: tenant.admin_email, company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, subdomain: tenant.subdomain }

    assert_redirected_to admin_tenants_url
  end

  test "should destroy tenant" do
    assert_difference('Admin::Tenant.count', -1) do
      delete :destroy, id: @tenant
    end

    assert_redirected_to admin_tenants_url
  end
end
