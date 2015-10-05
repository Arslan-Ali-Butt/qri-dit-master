class AddPhotoUrlToAdminLogos < ActiveRecord::Migration
  def change
    add_column :admin_logos, :photo_url, :string
  end
end
