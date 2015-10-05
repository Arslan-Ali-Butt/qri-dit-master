require 'test_helper'

class Tenant::ReportNotesControllerTest < ActionController::TestCase
  setup do
    @tenant_report_note = tenant_report_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tenant_report_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tenant_report_note" do
    assert_difference('Tenant::ReportNote.count') do
      post :create, tenant_report_note: {  }
    end

    assert_redirected_to tenant_report_note_path(assigns(:tenant_report_note))
  end

  test "should show tenant_report_note" do
    get :show, id: @tenant_report_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tenant_report_note
    assert_response :success
  end

  test "should update tenant_report_note" do
    patch :update, id: @tenant_report_note, tenant_report_note: {  }
    assert_redirected_to tenant_report_note_path(assigns(:tenant_report_note))
  end

  test "should destroy tenant_report_note" do
    assert_difference('Tenant::ReportNote.count', -1) do
      delete :destroy, id: @tenant_report_note
    end

    assert_redirected_to tenant_report_notes_path
  end
end
