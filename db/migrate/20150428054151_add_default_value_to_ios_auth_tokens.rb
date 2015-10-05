class AddDefaultValueToIosAuthTokens < ActiveRecord::Migration
  def change
    change_column_default :tenant_users, :ios_auth_tokens, '{}'
  end
end
