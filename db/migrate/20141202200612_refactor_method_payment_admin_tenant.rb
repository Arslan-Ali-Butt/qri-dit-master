class RefactorMethodPaymentAdminTenant < ActiveRecord::Migration
  def up
    change_table :admin_tenants do |t|
      t.rename :payment_card_last4,:card_last4
      t.change :card_last4, :string, limit: 4
      t.rename :card_type,:card_brand
    end
  end

  def down
    change_table :admin_tenants do |t|
      t.rename :card_last4, :payment_card_last4
      t.change :payment_card_last4, :string, limit: 255
      t.rename :card_brand, :card_type
    end
  end
end
