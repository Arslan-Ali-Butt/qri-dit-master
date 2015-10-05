class CreateTenantUserImports < ActiveRecord::Migration
  def change
    create_table :tenant_user_imports do |t|
      t.string :user_import_file
      t.integer :num_users
      t.integer :status
      t.string :error_messages, array: true, default: []
      t.string :type

      t.timestamps
    end
  end
end
