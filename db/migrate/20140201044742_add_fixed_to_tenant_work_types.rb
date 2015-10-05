class AddFixedToTenantWorkTypes < ActiveRecord::Migration
  def change
    add_column :tenant_work_types, :fixed, :boolean, default: false
  end
end
