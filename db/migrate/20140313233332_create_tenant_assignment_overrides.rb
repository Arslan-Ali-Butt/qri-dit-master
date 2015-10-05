class CreateTenantAssignmentOverrides < ActiveRecord::Migration
  def change
    create_table :tenant_assignment_overrides do |t|
      t.references :assignment, index: true
      t.references :assignee, index: true
      t.references :qrid, index: true
      t.string :comment
      t.string :status
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :deleted
      t.boolean :multiple_instance

      t.timestamps
    end
  end
end
