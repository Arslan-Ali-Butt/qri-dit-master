class AddAlarmSettingsToQrid < ActiveRecord::Migration
  def change
    add_column :tenant_qrids, :alarm_code, :string
    add_column :tenant_qrids, :alarm_safeword, :string
    add_column :tenant_qrids, :alarm_company, :string
    add_column :tenant_qrids, :key_box_code, :string
  end
end
