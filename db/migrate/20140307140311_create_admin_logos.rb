class CreateAdminLogos < ActiveRecord::Migration
  def change
    create_table :admin_logos do |t|
      t.integer :tenant_id

      t.timestamps
    end
  end
end
