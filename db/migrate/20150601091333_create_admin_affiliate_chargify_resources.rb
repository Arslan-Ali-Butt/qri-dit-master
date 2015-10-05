class CreateAdminAffiliateChargifyResources < ActiveRecord::Migration
  def change
    create_table :admin_affiliate_chargify_resources do |t|
      t.string :base_component_id
      t.string :qrids_component_id
      t.references :tenant, index: true

      t.timestamps
    end
  end
end
