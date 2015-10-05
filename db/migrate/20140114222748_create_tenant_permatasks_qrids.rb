class CreateTenantPermatasksQrids < ActiveRecord::Migration
  def change
    create_table :tenant_permatasks_qrids, { id: false } do |t|
      t.references :qrid
      t.references :permatask
    end
    add_index :tenant_permatasks_qrids, :qrid_id
  end
end
