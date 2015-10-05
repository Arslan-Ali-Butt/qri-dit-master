class RenameIosAuthTokens < ActiveRecord::Migration
  def change
    rename_column :tenant_users, :ios_auth_token, :ios_auth_tokens
  end
end
