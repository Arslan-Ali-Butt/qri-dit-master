class AddPhotoUrlToTenantReportPhotos < ActiveRecord::Migration
  def change
    add_column :tenant_report_photos, :photo_url, :string
  end
end
