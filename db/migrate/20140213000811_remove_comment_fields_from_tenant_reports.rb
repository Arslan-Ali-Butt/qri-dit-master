class RemoveCommentFieldsFromTenantReports < ActiveRecord::Migration
  def change
    remove_column :tenant_reports, :comment_text
    remove_column :tenant_reports, :reply_text
  end
end
