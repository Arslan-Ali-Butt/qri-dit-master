class CreateTenantAddresses < ActiveRecord::Migration
  def change
    create_table :tenant_addresses do |t|
      t.references :addressable, polymorphic: true
      t.string :house_number
      t.string :street_name
      t.string :line_2
      t.string :city
      t.string :province
      t.string :postal_code
      t.string :country

      t.timestamps
    end
  end
end
