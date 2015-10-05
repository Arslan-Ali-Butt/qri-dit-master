class AddReportUnreadNotesCountToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :report_unread_notes_count, :integer, default: 0
  end
end
