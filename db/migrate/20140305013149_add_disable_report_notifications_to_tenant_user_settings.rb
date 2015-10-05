class AddDisableReportNotificationsToTenantUserSettings < ActiveRecord::Migration
  def change
    add_column :tenant_user_settings, :disable_report_notifications, :boolean
  end
end
