class AddItemNameToAdminPriceplanAddons < ActiveRecord::Migration
  def change
    add_column :admin_priceplan_addons, :item_name, :string
  end
end
