class AddDeltaToTenantUsers < ActiveRecord::Migration
  def change
    add_column :tenant_users, :delta, :boolean, default: true, null: false
    add_index  :tenant_users, :delta
  end
end
