class AddBillingSubscriptionIdToAdminTenants < ActiveRecord::Migration
  def change
    change_table :admin_tenants do |t|
      t.string :billing_subscription_id
    end  
  end
end
