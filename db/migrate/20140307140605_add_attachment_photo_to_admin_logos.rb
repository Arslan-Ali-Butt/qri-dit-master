class AddAttachmentPhotoToAdminLogos < ActiveRecord::Migration
  def self.up
    change_table :admin_logos do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :admin_logos, :photo
  end
end
