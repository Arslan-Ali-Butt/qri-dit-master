class RenameInspectorsToReporters < ActiveRecord::Migration
  def up
    Tenant::Role.connection.execute("update tenant_roles set name='Reporter' where name='Inspector'")
  end

  def down
    Tenant::Role.connection.execute("update tenant_roles set name='Inspector' where name='Reporter'")
  end
end
