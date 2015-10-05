class CreateTenantAssignments < ActiveRecord::Migration
  def change
    create_table :tenant_assignments do |t|
      t.integer :assignee_id
      t.references :qrid
      t.string :comment
      t.string :status
      t.boolean :permatask
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
    add_index :tenant_assignments, :assignee_id
  end
end
