class AddRecurringUntilAtToTenantAssignmentOverrides < ActiveRecord::Migration
  def change
    add_column :tenant_assignment_overrides, :recurring_until_at, :datetime
  end
end
