class AddOverridedStartAtToTenantAssignmentOverrides < ActiveRecord::Migration
  def change
    add_column :tenant_assignment_overrides, :overrided_start_at, :datetime
  end
end
