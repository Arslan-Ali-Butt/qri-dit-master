class CreateTenantRoles < ActiveRecord::Migration
  def change
    create_table :tenant_roles do |t|
      t.string :name
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :tenant_roles, :name, unique: true
  end
end
