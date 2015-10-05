class AddDisableAssignmentNotificationsToTenantUserSettings < ActiveRecord::Migration
  def change
    add_column :tenant_user_settings, :disable_assignment_notifications, :boolean
  end
end
