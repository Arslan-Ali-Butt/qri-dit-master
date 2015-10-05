class AddGoToAffiliateBoolean < ActiveRecord::Migration
  def change
    add_column :tenant_tasks, :for_affiliates, :boolean, default: false
  end
end
