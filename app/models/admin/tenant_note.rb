class Admin::TenantNote < ActiveRecord::Base
  belongs_to :tenant
  belongs_to :author, class_name: 'Admin::Landlord', foreign_key: :author_id

  validates :title,     presence: true
  validates :note,      presence: true
  validates :author_id, presence: true

  strip_attributes allow_empty: true

  def display_name; 'Note' end

  def collection_id; self.tenant_id end
end
