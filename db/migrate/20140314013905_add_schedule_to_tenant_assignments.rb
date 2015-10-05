class AddScheduleToTenantAssignments < ActiveRecord::Migration
  def change
    add_column :tenant_assignments, :schedule, :text
  end
end
