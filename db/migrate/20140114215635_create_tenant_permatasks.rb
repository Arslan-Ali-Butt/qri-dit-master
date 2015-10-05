class CreateTenantPermatasks < ActiveRecord::Migration
  def change
    create_table :tenant_permatasks do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name
      t.string :task_type
      t.boolean :active

      t.timestamps
    end
    add_index :tenant_permatasks, :parent_id
    add_index :tenant_permatasks, :lft
    add_index :tenant_permatasks, :rgt
  end
end
