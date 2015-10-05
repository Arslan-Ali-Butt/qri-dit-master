class ChangeTenantAssignmentsRecurrence < ActiveRecord::Migration
  def change
    remove_column :tenant_assignments, :recurrence
    add_column :tenant_assignments, :recurrence, :string
  end
end
