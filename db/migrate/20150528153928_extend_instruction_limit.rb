class ExtendInstructionLimit < ActiveRecord::Migration
  def up
    change_column :tenant_assignments, :comment, :text, limit: 4096
    change_column :tenant_assignment_overrides, :comment, :text, limit: 4096
    change_column :tenant_sites, :instruction, :text, limit: 4096
    change_column :tenant_qrids, :instruction, :text, limit: 4096
  end
  def down
    change_column :tenant_assignments, :comment, :string
    change_column :tenant_assignment_overrides, :comment, :string
    change_column :tenant_sites, :instruction, :string
    change_column :tenant_qrids, :instruction, :string
  end
end
