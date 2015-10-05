class ChangeEndedAtInTenantReports < ActiveRecord::Migration
  def change
    rename_column :tenant_reports, :ended_at, :submitted_at
  end
end
