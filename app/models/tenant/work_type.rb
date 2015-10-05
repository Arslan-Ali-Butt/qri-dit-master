class Tenant::WorkType < ActiveRecord::Base
  has_many :qrids, dependent: :restrict_with_exception
  has_many :tasks, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  strip_attributes allow_empty: true

  def display_name; "Work type#{self.name.present? ? " '#{self.name}'" : ''}" end
end
