class AddTypeToUsers < ActiveRecord::Migration
  def change
    add_column :tenant_users, :type, :string
  end
end
