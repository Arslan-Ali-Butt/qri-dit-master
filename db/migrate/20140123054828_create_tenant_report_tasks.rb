class CreateTenantReportTasks < ActiveRecord::Migration
  def change
    create_table :tenant_report_tasks do |t|
      t.references :report
      t.integer :task_id
      t.string :task_type
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
