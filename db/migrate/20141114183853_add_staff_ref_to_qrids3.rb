class AddStaffRefToQrids3 < ActiveRecord::Migration
  def change
    remove_column :tenant_qrids, :updated_tenant_staff_id
    remove_column :tenant_qrids, :created_tenant_staff_id
    add_reference :tenant_qrids, :updated_tenant_staff, polymorphic: true
    add_reference :tenant_qrids, :created_tenant_staff, polymorphic: true
  end
end
