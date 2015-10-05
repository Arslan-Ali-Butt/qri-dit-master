class AddStaffRefToQrids2 < ActiveRecord::Migration
  def change
    remove_column :tenant_qrids, :tenant_staff_id  	
    add_reference :tenant_qrids, :updated_tenant_staff, polymorphic: false, index: true
    add_reference :tenant_qrids, :created_tenant_staff, polymorphic: false, index: true
  end
end
