class AddUnreadByManagerToTenantReportNotes < ActiveRecord::Migration
  def change
    add_column :tenant_report_notes, :unread_by_manager, :boolean, default: true
  end
end
