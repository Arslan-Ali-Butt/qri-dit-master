class AddReporterTimeDataToTenantUsers < ActiveRecord::Migration
  def change
    add_column :tenant_users, :last_report_at, :datetime
    add_column :tenant_users, :time_this_week, :integer, default: 0
    add_column :tenant_users, :time_this_month, :integer, default: 0
  end
end
