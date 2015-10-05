class AddPositionToPermaTasks < ActiveRecord::Migration
  def change
    add_column :tenant_permatasks, :position, :integer
    add_column :tenant_permatasks, :children_count, :integer
  end
end
