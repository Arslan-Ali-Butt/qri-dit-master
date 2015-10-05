class AddAllowReportersToViewReportsToAdminTenants < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :allow_reporters_to_view_reports, :boolean, default: true
  end
end
