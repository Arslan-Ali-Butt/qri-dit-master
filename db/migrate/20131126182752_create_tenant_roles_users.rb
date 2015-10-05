class CreateTenantRolesUsers < ActiveRecord::Migration
  def change
    create_table :tenant_roles_users, { id: false } do |t|
      t.references :role
      t.references :user
    end
    add_index :tenant_roles_users, :role_id
    add_index :tenant_roles_users, :user_id
  end
end
