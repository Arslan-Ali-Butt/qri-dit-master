class AddStripeCustomerIdToAdminTenants < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :stripe_customer_id, :string
  end
end
