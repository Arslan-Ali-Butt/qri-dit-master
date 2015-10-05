class CreateTenantReportPhotos < ActiveRecord::Migration
  def change
    create_table :tenant_report_photos do |t|
      t.references :report
      t.integer :task_id

      t.timestamps
    end
  end
end
