class CreateTenantWorkTypesUsers < ActiveRecord::Migration
  def up
    create_table :tenant_staff_work_types_users, { id: false } do |t|
      t.references :user
      t.references :work_type
    end
    add_index :tenant_staff_work_types_users, :user_id

    remove_column :tenant_users, :staff_work_type_id
  end

  def down
    drop_table :tenant_staff_work_types_users

    add_column :tenant_users, :staff_work_type_id, :integer
  end
end
