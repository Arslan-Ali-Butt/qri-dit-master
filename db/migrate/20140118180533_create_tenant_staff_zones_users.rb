class CreateTenantStaffZonesUsers < ActiveRecord::Migration
  def change
    create_table :tenant_staff_zones_users, { id: false } do |t|
      t.references :user
      t.references :zone
    end
    add_index :tenant_staff_zones_users, :user_id
  end
end
