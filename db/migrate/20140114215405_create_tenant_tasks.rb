class CreateTenantTasks < ActiveRecord::Migration
  def change
    create_table :tenant_tasks do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name
      t.string :task_type
      t.references :work_type
      t.string :client_type
      t.boolean :active

      t.references :qrid
      t.integer :origin_id
      t.boolean :checked

      t.timestamps
    end
    add_index :tenant_tasks, :parent_id
    add_index :tenant_tasks, :lft
    add_index :tenant_tasks, :rgt
    add_index :tenant_tasks, :qrid_id
  end
end
