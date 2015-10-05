class AddAssignmentNotificationTimeToAdminTenants < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :assignment_notification_time, :integer, default: 7
  end
end
