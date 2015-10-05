class AddInstructionsToModels < ActiveRecord::Migration
  def change
    add_column :tenant_sites, :instruction, :string
    add_column :tenant_qrids, :instruction, :string
  end
end
