class AddLogoCacheToAdminTenants < ActiveRecord::Migration
  def change
  	add_column :admin_tenants, :logo_cache, :string
  end
end
