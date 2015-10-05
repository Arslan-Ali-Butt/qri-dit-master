require 'test_helper'

class Admin::TenantNotesControllerTest < ActionController::TestCase
  setup do
    @admin_tenant_note = admin_tenant_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_tenant_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_tenant_note" do
    assert_difference('Admin::TenantNote.count') do
      post :create, admin_tenant_note: {  }
    end

    assert_redirected_to admin_tenant_note_path(assigns(:admin_tenant_note))
  end

  test "should show admin_tenant_note" do
    get :show, id: @admin_tenant_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_tenant_note
    assert_response :success
  end

  test "should update admin_tenant_note" do
    patch :update, id: @admin_tenant_note, admin_tenant_note: {  }
    assert_redirected_to admin_tenant_note_path(assigns(:admin_tenant_note))
  end

  test "should destroy admin_tenant_note" do
    assert_difference('Admin::TenantNote.count', -1) do
      delete :destroy, id: @admin_tenant_note
    end

    assert_redirected_to admin_tenant_notes_path
  end
end
