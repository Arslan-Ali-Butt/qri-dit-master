class AddNextAssignmentTimestampToTenantQrids < ActiveRecord::Migration
  def change
    add_column :tenant_qrids, :next_assignment_timestamp, :integer
    add_column :tenant_qrids, :next_assignment_timestamp_stale, :boolean, default: true
  end
end
