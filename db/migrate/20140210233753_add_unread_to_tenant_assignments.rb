class AddUnreadToTenantAssignments < ActiveRecord::Migration
  def change
    add_column :tenant_assignments, :unread, :boolean
  end
end
