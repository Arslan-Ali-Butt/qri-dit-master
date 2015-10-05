class CreateTenantUsers < ActiveRecord::Migration
  def change
    create_table :tenant_users do |t|
      t.string :name

      t.string :phone_cell
      t.string :phone_landline
      t.string :phone_emergency
      t.string :phone_emergency_2

      t.integer :staff_work_type_id
      t.string :staff_daily_hours

      t.string :client_type
      t.text :notes

      t.string :status, default: 'Active'
      t.boolean :super_user, default: false

      t.timestamps
    end
  end
end
