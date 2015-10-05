class AddAcronymToTenant < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :acronym, :string
  end
end
