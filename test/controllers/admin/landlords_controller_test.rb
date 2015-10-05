require 'test_helper'

class Admin::LandlordsControllerTest < ActionController::TestCase
  setup do
    @request.host = "admin.#{@request.host}"

    Admin::LandlordsController.any_instance.stubs(:authorize).returns(true)
    @landlord = FactoryGirl.create(:landlord)
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
    get :edit, id: @landlord
    assert_response :success
  end

  test "should create landlord" do
    landlord = FactoryGirl.build(:landlord)
    assert_difference('Admin::Landlord.count', 1) do
      post :create, admin_landlord: { name: landlord.name, password: landlord.password, password_confirmation: landlord.password_confirmation }
    end

    assert_redirected_to admin_landlords_url
  end

  test "should update landlord" do
    landlord = FactoryGirl.build(:landlord)
    patch :update, id: @landlord, admin_landlord: { name: landlord.name, password: landlord.password, password_confirmation: landlord.password_confirmation }

    assert_redirected_to admin_landlords_url
  end

  test "should destroy landlord" do
    landlord = FactoryGirl.create(:landlord)
    assert_difference('Admin::Landlord.count', -1) do
      delete :destroy, id: landlord
    end

    assert_redirected_to admin_landlords_url
  end

  test "should not destroy last landlord" do
    assert_no_difference('Admin::Landlord.count') do
      delete :destroy, id: @landlord
    end

    assert_redirected_to admin_landlords_url
  end
end
