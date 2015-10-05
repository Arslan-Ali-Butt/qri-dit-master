class AddPositionToTask < ActiveRecord::Migration
  def change
    add_column :tenant_tasks, :position, :integer
    add_column :tenant_tasks, :children_count, :integer
  end
end
