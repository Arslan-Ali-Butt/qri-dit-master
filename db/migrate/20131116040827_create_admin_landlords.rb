class CreateAdminLandlords < ActiveRecord::Migration
  def change
    create_table :admin_landlords do |t|
      t.string :name
      t.string :hashed_password
      t.string :salt
      t.datetime :last_login_at

      t.timestamps
    end
    add_index :admin_landlords, :name, unique: true
  end
end
