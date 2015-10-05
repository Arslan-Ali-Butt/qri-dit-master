class AddDeltaToTenantQrids < ActiveRecord::Migration
  def change
    add_column :tenant_qrids, :delta, :boolean, default: true, null: false
    add_index  :tenant_qrids, :delta
  end
end
