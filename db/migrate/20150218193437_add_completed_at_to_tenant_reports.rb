class AddCompletedAtToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :completed_at, :datetime
  end
end
