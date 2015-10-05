class AddPhotoUrlToTenantQridPhotos < ActiveRecord::Migration
  def change
    add_column :tenant_qrid_photos, :photo_url, :string
  end
end
