class AddParrentAndApprovedToAdminTenant < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :parent_id, :integer
    add_column :admin_tenants, :affiliate_status, :string, default: "AWAITING_APPROVAL"
  end
end
