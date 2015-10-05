class AddForAffililiatestoPermaTasks < ActiveRecord::Migration
  def change
    add_column :tenant_permatasks, :for_affiliates, :boolean, default: false
  end
end
