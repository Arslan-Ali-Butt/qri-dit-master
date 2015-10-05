class AddAllowClientViewCommentsToAdminTenants < ActiveRecord::Migration
  def change
    change_table :admin_tenants do |t|
      t.boolean :allow_clients_view_comments, default: false
    end
  end
end
