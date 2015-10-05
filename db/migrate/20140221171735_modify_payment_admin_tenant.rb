class ModifyPaymentAdminTenant < ActiveRecord::Migration
  def change
    change_table :admin_tenants do |t|
      t.rename :payment_customer_id, :billing_customer_id
      t.rename :payment_card_type, :card_type      
      # t.rename :payment_card_last4, :card_last4      
      remove_column :admin_tenants, :payment_coupon
      t.rename :payment_recurrence, :billing_recurrence
    end
  end
end
