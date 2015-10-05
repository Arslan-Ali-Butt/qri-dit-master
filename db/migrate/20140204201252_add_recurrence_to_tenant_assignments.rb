class AddRecurrenceToTenantAssignments < ActiveRecord::Migration
  def change
    add_column :tenant_assignments, :recurrence, :string, default: ''
    add_column :tenant_assignments, :recurring_until_at, :datetime
  end
end
