require 'test_helper'

class Tenant::MySitesControllerTest < ActionController::TestCase
  setup do
    @client_role = FactoryGirl.create(:role, name: 'Client')
    @current_user = FactoryGirl.build(:user, role_ids: [@client_role.id])
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user

    @site = FactoryGirl.create(:site, owner_id: @current_user.id)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show site" do
    get :show, id: @site
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @site
    assert_response :success
  end

  test "should create site" do
    site = FactoryGirl.build(:site)

    assert_difference('@current_user.sites.count', 1) do
      post :create, tenant_site: { owner_id: 123, name: site.name, address_1: site.address_1, address_2: site.address_2, city: site.city, province: site.province, zipcode: site.zipcode, zone: site.zone, alarm_code: site.alarm_code, alarm_safeword: site.alarm_safeword, alarm_company: site.alarm_company, emergency_number: site.emergency_number }
    end

    assert_redirected_to tenant_my_sites_url
  end

  test "should update site" do
    site = FactoryGirl.build(:site)

    assert_no_difference('@current_user.sites.count') do
      patch :update, id: @site, tenant_site: { owner_id: 321, name: site.name, address_1: site.address_1, address_2: site.address_2, city: site.city, province: site.province, zipcode: site.zipcode, zone: site.zone, alarm_code: site.alarm_code, alarm_safeword: site.alarm_safeword, alarm_company: site.alarm_company, emergency_number: site.emergency_number }
    end

    assert_redirected_to tenant_my_sites_url
  end

  test "should destroy site" do
    assert_difference('@current_user.sites.count', -1) do
      delete :destroy, id: @site
    end

    assert_redirected_to tenant_my_sites_url
  end
end
