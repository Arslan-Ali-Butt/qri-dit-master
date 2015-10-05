class AddIsPermataskReportToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :is_permatask_report, :boolean, default: false
  end
end
