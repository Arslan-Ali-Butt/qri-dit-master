class AddUnreadToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :unread_by_manager, :boolean
    add_column :tenant_reports, :unread_by_client, :boolean
    add_column :tenant_reports, :flagged, :boolean
  end
end
