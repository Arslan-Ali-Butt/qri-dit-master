class CreateAdminPriceplanAddons < ActiveRecord::Migration
  def change
    create_table :admin_priceplan_addons do |t|
      t.string :name
      t.integer :starting_number
      t.integer :ending_number
      t.decimal :unit_price, precision: 8, scale: 2
      t.references :priceplan, index: true

      t.timestamps
    end
  end
end
