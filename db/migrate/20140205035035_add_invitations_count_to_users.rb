class AddInvitationsCountToUsers < ActiveRecord::Migration
  def change
    add_column :tenant_users, :invitations_count, :integer
  end
end
