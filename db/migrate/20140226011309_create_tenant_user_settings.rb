class CreateTenantUserSettings < ActiveRecord::Migration
  def change
    create_table :tenant_user_settings do |t|
      t.references :user
      t.boolean :getting_started_popup_shown
    end
    add_index :tenant_user_settings, :user_id
  end
end
