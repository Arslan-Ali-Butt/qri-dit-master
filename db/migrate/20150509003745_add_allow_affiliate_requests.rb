class AddAllowAffiliateRequests < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :allow_affiliate_requests, :boolean, default: false
  end
end
