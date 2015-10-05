class Tenant::Permatask < ActiveRecord::Base
  include Sortable

  has_paper_trail

  has_and_belongs_to_many :qrids

  # validates :name, presence: true, uniqueness: {scope: :parent_id}

  after_create :add_default_children

  strip_attributes allow_empty: true

  def display_name; 'Permatask' end

  def can_be_nested_in?(parent_id)
    parent_id.to_i == 0 || NESTING_RULES[Tenant::Permatask.find(parent_id).task_type].include?(self.task_type)
  end

  private

  def add_default_children
    if self.task_type == 'Question'
      ['Yes', 'No', 'N/A'].each do |answer|
        child = Tenant::Permatask.create!(
            name: answer,
            task_type: 'Answer',
            active: self.active
        )
        child.move_to_child_of(self)
      end
    end
  end
end