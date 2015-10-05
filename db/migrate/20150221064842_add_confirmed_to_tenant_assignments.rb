class AddConfirmedToTenantAssignments < ActiveRecord::Migration
  def change
    add_column :tenant_assignments, :confirmed, :boolean, default: false
  end
end
