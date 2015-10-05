class Tenant::MyAssignmentsController < Tenant::AssignmentsController
  prepend_before_action :set_assignee

  private
  def set_assignee; @assignee_id = current_user.try(:id) end
end
