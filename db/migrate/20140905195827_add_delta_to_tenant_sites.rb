class AddDeltaToTenantSites < ActiveRecord::Migration
  def change
    add_column :tenant_sites, :delta, :boolean, default: true, null: false
    add_index  :tenant_sites, :delta
  end
end
