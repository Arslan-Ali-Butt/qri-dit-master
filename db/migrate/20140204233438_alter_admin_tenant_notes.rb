class AlterAdminTenantNotes < ActiveRecord::Migration
  def change
    create_table :admin_tenant_notes do |t|
      t.references :tenant
      t.string :title
      t.text :note
      t.integer :author_id

      t.timestamps
    end
  end
end
