class AddCommentsToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :comments, :text
  end
end
