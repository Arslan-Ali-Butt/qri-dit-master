class CreateTenantReports < ActiveRecord::Migration
  def change
    create_table :tenant_reports do |t|
      t.references :assignment
      t.references :qrid
      t.integer :reporter_id
      t.datetime :started_at
      t.datetime :ended_at

      t.text :comment_text
      t.datetime :sent_at
      t.datetime :received_at
      t.text :reply_text
      t.datetime :replied_at

      t.timestamps
    end
  end
end
