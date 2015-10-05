class AddDepthToPermatasks < ActiveRecord::Migration
  def change
    change_table :tenant_permatasks do |t|
      t.integer :depth
    end
  end
end
