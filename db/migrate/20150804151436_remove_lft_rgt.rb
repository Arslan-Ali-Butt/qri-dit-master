class RemoveLftRgt < ActiveRecord::Migration
  def change
    remove_column :tenant_tasks, :lft
    remove_column  :tenant_tasks, :rgt
    remove_column :tenant_permatasks, :lft
    remove_column :tenant_permatasks, :rgt
  end
end
