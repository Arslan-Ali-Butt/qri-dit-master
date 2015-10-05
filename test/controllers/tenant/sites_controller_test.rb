require 'test_helper'

class Tenant::SitesControllerTest < ActionController::TestCase
  setup do
    @manager_role = FactoryGirl.create(:role, name: 'Manager')
    @current_user = FactoryGirl.build(:user, role_ids: [@manager_role.id])
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user

    @client_role = FactoryGirl.create(:role, name: 'Client')
    @client_user = FactoryGirl.build(:user, role_ids: [@client_role.id])
    @client_user.invite!
    @client_user.accept_invitation!

    @site = FactoryGirl.create(:site, owner_id: @client_user.id)
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

    assert_difference('@client_user.sites.count', 1) do
      post :create, tenant_site: { owner_id: @client_user.id, name: site.name, address_1: site.address_1, address_2: site.address_2, city: site.city, province: site.province, zipcode: site.zipcode, zone: site.zone, alarm_code: site.alarm_code, alarm_safeword: site.alarm_safeword, alarm_company: site.alarm_company, emergency_number: site.emergency_number }
    end

    assert_redirected_to tenant_sites_url
  end

  test "should update site" do
    site = FactoryGirl.build(:site)

    assert_no_difference('@client_user.sites.count') do
      patch :update, id: @site, tenant_site: { owner_id: @client_user.id, name: site.name, address_1: site.address_1, address_2: site.address_2, city: site.city, province: site.province, zipcode: site.zipcode, zone: site.zone, alarm_code: site.alarm_code, alarm_safeword: site.alarm_safeword, alarm_company: site.alarm_company, emergency_number: site.emergency_number }
    end

    assert_redirected_to tenant_sites_url
  end

  test "should destroy site" do
    assert_difference('@client_user.sites.count', -1) do
      delete :destroy, id: @site
    end

    assert_redirected_to tenant_sites_url
  end
end
