class AddIosAuthTokenToTenantUsers < ActiveRecord::Migration
  def change
    add_column :tenant_users, :ios_auth_token, :string
  end
end
