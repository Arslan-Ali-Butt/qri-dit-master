class CreateTenantQrids < ActiveRecord::Migration
  def change
    create_table :tenant_qrids do |t|
      t.references :site
      t.references :work_type
      t.string :name
      t.decimal :estimated_duration, precision: 5, scale: 2

      t.string :status, default: 'Active'

      t.timestamps
    end
  end
end
