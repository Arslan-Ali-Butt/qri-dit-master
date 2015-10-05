class ChangeIosAuthTokensToArray < ActiveRecord::Migration
  def change
    change_column :tenant_users, :ios_auth_tokens, "text[] USING (string_to_array(ios_auth_tokens, ','))"
  end
end
