class AddLoggedToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :logged, :integer, default: 0
  end
end
