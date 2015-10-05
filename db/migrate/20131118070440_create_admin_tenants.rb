class CreateAdminTenants < ActiveRecord::Migration
  def change
    create_table :admin_tenants do |t|
      t.string :subdomain
      t.string :company_name
      t.string :company_website
      t.string :name
      t.string :phone
      t.string :phone_ext
      t.string :admin_email
      t.string :timezone, default: 'Eastern Time (US & Canada)'
      t.string :host_url

      t.references :priceplan
      t.string :payment_customer_id
      t.string :payment_card_type
      t.string :payment_card_last4
      t.string :payment_recurrence
      t.string :payment_coupon

      t.timestamps
    end
    add_index :admin_tenants, :subdomain, unique: true
  end
end
