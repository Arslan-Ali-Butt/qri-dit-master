class AddNewSettingsToAdminTenant < ActiveRecord::Migration
  def change
	change_table :admin_tenants do |t|
		t.boolean :metric, default: true
		t.string :country_code, default: 'CA'	
	end
  end
end
