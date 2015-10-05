class AddAttachmentPhotoToTenantReportPhotos < ActiveRecord::Migration
  def up
    change_table :tenant_report_photos do |t|
      t.attachment :photo
    end
  end

  def down
    drop_attached_file :tenant_report_photos, :photo
  end
end
