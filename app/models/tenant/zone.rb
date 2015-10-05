class Tenant::Zone < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  strip_attributes allow_empty: true

  def display_name; "Zone#{self.name.present? ? " '#{self.name}'" : ''}" end
end
