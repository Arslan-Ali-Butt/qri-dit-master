class AddAllowCommentEmailNotificationsToAdminTenants < ActiveRecord::Migration
  def change
    add_column :admin_tenants, :allow_comment_email_notifications, :boolean, default: true
  end
end
