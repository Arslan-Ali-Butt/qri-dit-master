class AddLatestUnreadClientCommentTimestampToTenantReports < ActiveRecord::Migration
  def change
    add_column :tenant_reports, :latest_unread_client_comment_timestamp, :integer, default: 0
  end
end
