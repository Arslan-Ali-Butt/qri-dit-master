class AddInviteClientsOnCreateToAdminTenants < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :invite_clients_on_create, :boolean, default: true
  end
end
