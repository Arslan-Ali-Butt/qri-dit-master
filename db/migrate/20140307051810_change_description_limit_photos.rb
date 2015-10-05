class ChangeDescriptionLimitPhotos < ActiveRecord::Migration
  def change
  	change_column :tenant_qrid_photos, :description, :string, :limit => 300
  end
end
