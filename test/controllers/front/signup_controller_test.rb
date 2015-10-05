require 'test_helper'

class Front::SignupControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success

    tenant = assigns(:tenant)
    assert_not_nil tenant
    assert tenant.first_step?
  end

  test "should create tenant in multi steps" do
    new_tenant = tenant = FactoryGirl.build(:tenant, current_step: Admin::Tenant.first_step)

    assert_no_difference('Admin::Tenant.count') do
      post :create, signup: { company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, current_step: tenant.current_step }
    end
    assert_response :success

    tenant = assigns(:tenant)
    assert_not_nil tenant
    tenant.previous_step!
    assert tenant.valid?, "Invalid tenant after 1st step of signup"
    tenant.next_step!

    assert_no_difference('Admin::Tenant.count') do
      post :create, signup: { admin_email: new_tenant.admin_email, subdomain: new_tenant.subdomain, company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, current_step: tenant.current_step }
    end
    assert_response :success

    tenant = assigns(:tenant)
    assert_not_nil tenant
    tenant.previous_step!
    assert tenant.valid?, "Invalid tenant after 2nd step of signup"
    tenant.next_step!

    assert_no_difference('Admin::Tenant.count') do
      post :create, signup: { admin_email: tenant.admin_email, subdomain: tenant.subdomain, company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, current_step: tenant.current_step }
    end
    assert_response :success

    tenant = assigns(:tenant)
    assert_not_nil tenant
    tenant.previous_step!
    assert tenant.valid?, "Invalid tenant after 3nd step of signup"
    tenant.next_step!

    assert_difference('Admin::Tenant.count', 1) do
      assert tenant.last_step?
      post :create, signup: { admin_email: tenant.admin_email, subdomain: tenant.subdomain, company_name: tenant.company_name, company_website: tenant.company_website, name: tenant.name, phone: tenant.phone, phone_ext: tenant.phone_ext, current_step: tenant.current_step }
    end
    assert_redirected_to signup_thanks_url
  end

  test "should get thanks" do
    get :thanks
    assert_response :success
  end
end
