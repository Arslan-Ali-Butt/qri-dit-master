class RenameHomewatchToHomeWatch < ActiveRecord::Migration
  def up
    Tenant::Role.connection.execute("update tenant_work_types set name='Home Watch' where name='Homewatch'")
  end

  def down
    Tenant::Role.connection.execute("update tenant_work_types set name='Homewatch' where name='Home Watch'")
  end
end
