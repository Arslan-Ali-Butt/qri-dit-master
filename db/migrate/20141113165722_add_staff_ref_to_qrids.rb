class AddStaffRefToQrids < ActiveRecord::Migration
  def change
    change_table :tenant_qrids do |t|
      t.belongs_to :tenant_staff
    end
  end
end
