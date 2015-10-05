class CreateTenantSites < ActiveRecord::Migration
  def change
    create_table :tenant_sites do |t|
      t.integer :owner_id
      t.string :name
      t.integer :zone_id

      t.string :alarm_code
      t.string :alarm_safeword
      t.string :alarm_company
      t.string :emergency_number

      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      t.text :notes
      t.string :status, default: 'Active'

      t.timestamps
    end
    add_index :tenant_sites, :owner_id
  end
end
