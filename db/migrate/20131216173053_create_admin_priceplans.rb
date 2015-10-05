class CreateAdminPriceplans < ActiveRecord::Migration
  def change
    create_table :admin_priceplans do |t|
      t.string :name
      t.string :title
      t.integer :qrid_num
      t.decimal :price_per_month, precision: 8, scale: 2
      t.decimal :price_per_year, precision: 8, scale: 2
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
