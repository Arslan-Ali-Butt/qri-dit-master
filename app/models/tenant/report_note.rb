class Tenant::ReportNote < ActiveRecord::Base
  belongs_to :report

  belongs_to :author, class_name: 'Tenant::User', foreign_key: :author_id

  validates :author_id, presence: true

  strip_attributes allow_empty: true

  after_save :update_unread_notes_counter_cache

  after_save :update_latest_unread_client_note_timestamp

  after_destroy :update_unread_notes_counter_cache

  def display_name; 'Comment' end

  def collection_id; self.report_id end

  def self.by_author_role(role)
    joins(author: :roles).where(tenant_roles: {name: role}).distinct.readonly(false)
  end

  def update_unread_notes_counter_cache
    self.report.report_unread_notes_count = Tenant::Report.where(unread_by_manager: true).count
    self.report.save
  end

  def update_latest_unread_client_note_timestamp
    if self.author.type == 'Tenant::Client'
      self.report.latest_unread_client_comment_timestamp = self.created_at.to_i
      self.report.save
    end
  end
end
