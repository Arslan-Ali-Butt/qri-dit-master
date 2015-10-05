class RemoveAdminTenantLogoCache < ActiveRecord::Migration
  def change
  	remove_column :admin_tenants, :logo_cache
  end
end
