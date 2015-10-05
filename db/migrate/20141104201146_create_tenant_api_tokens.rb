class CreateTenantApiTokens < ActiveRecord::Migration
  def change
    create_table :tenant_api_tokens do |t|
      t.string :token
      t.references :user, index: true

      t.timestamps
    end
  end
end
