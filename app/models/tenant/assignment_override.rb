class Tenant::AssignmentOverride < ActiveRecord::Base
  include IceCube

  belongs_to :assignment, class_name: 'Tenant::Assignment', foreign_key: :assignment_id

  belongs_to :assignee, class_name: 'Tenant::Staff', foreign_key: :assignee_id
  belongs_to :qrid

  STATUSES = ['Open', 'In Progress', 'Done']

  validates :assignee, presence: true
  validates :qrid,     presence: true
  validates :status,      presence: true, inclusion: { in: STATUSES }
  validates :start_at,    presence: true
  validates :end_at,      presence: true

  strip_attributes allow_empty: true

  #after_save :notify_assignee

  before_validation do
    self.status = 'Open' unless self.status
    self.deleted = false unless self.deleted
  end
end
