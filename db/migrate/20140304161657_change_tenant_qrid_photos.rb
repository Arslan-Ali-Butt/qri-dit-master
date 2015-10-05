class ChangeTenantQridPhotos < ActiveRecord::Migration
  def change
  	remove_column :tenant_qrid_photos, :notes
  	add_column :tenant_qrid_photos, :title, :string, :limit => 100
  	add_column :tenant_qrid_photos, :description, :string, :limit => 150
  end
end
