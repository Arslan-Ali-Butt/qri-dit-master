class CreateTenantReportSolutions < ActiveRecord::Migration
  def change
    create_table :tenant_report_solutions do |t|
      t.references :report
      t.references :report_task
      t.text :description
      t.boolean :accepted
      t.boolean :declined

      t.timestamps
    end
  end
end
