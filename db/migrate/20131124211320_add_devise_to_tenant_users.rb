class AddDeviseToTenantUsers < ActiveRecord::Migration
  def change
    ## Database authenticatable
    add_column :tenant_users, :email, :string,              null: false, default: ''
    add_column :tenant_users, :encrypted_password, :string, null: false, default: ''

    ## Recoverable
    add_column :tenant_users, :reset_password_token, :string
    add_column :tenant_users, :reset_password_sent_at, :datetime

    ## Rememberable
    add_column :tenant_users, :remember_created_at, :datetime

    ## Trackable
    add_column :tenant_users, :sign_in_count, :integer, default: 0, null: false
    add_column :tenant_users, :current_sign_in_ip, :string
    add_column :tenant_users, :last_sign_in_ip, :string
    add_column :tenant_users, :current_sign_in_at, :datetime
    add_column :tenant_users, :last_sign_in_at, :datetime

    ## Confirmable
    add_column :tenant_users, :confirmation_token, :string
    add_column :tenant_users, :unconfirmed_email, :string # Only if using reconfirmable
    add_column :tenant_users, :confirmed_at, :datetime
    add_column :tenant_users, :confirmation_sent_at, :datetime

    ## Lockable
    add_column :tenant_users, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    add_column :tenant_users, :unlock_token, :string # Only if unlock strategy is :email or :both
    add_column :tenant_users, :locked_at, :datetime

    add_index :tenant_users, :email,                unique: true
    add_index :tenant_users, :reset_password_token, unique: true
    add_index :tenant_users, :confirmation_token,   unique: true
    add_index :tenant_users, :unlock_token,         unique: true
  end
end
