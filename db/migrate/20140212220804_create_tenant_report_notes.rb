class CreateTenantReportNotes < ActiveRecord::Migration
  def change
    create_table :tenant_report_notes do |t|
      t.references :report
      t.text :note
      t.integer :author_id

      t.timestamps
    end
  end
end
