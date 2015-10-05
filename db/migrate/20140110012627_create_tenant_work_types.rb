class CreateTenantWorkTypes < ActiveRecord::Migration
  def change
    create_table :tenant_work_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
