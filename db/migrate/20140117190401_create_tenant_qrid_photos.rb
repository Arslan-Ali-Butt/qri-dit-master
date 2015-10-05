class CreateTenantQridPhotos < ActiveRecord::Migration
  def change
    create_table :tenant_qrid_photos do |t|
      t.references :qrid
      t.text :notes

      t.timestamps
    end
  end
end
