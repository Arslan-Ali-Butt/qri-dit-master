require 'test_helper'

class Tenant::AssignmentsControllerTest < ActionController::TestCase
  setup do
    @manager_role = FactoryGirl.create(:role, name: 'Manager')
    @current_user = FactoryGirl.build(:user, role_ids: [@manager_role.id])
    @current_user.invite!
    @current_user.accept_invitation!
    sign_in @current_user
  end
end
