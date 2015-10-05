class AddDepthToTasks < ActiveRecord::Migration
  def change
    change_table :tenant_tasks do |t|
      t.integer :depth
    end
  end
end
