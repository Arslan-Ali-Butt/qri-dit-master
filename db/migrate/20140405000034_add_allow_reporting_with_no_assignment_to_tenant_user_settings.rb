class AddAllowReportingWithNoAssignmentToTenantUserSettings < ActiveRecord::Migration
  def change
    add_column :tenant_user_settings, :allow_reporting_with_no_assignment, :boolean, default: false
  end
end
