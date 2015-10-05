class AddAttachmentPhotoToTenantQridPhotos < ActiveRecord::Migration
  def up
    change_table :tenant_qrid_photos do |t|
      t.attachment :photo
    end
  end

  def down
    drop_attached_file :tenant_qrid_photos, :photo
  end
end
