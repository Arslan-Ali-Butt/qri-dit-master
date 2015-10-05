class Tenant::Task < ActiveRecord::Base
  include Sortable

  has_paper_trail

  belongs_to :work_type

  belongs_to :origin, class_name: 'Tenant::Task', foreign_key: :origin_id

  # validates :name, presence: true, uniqueness: {scope: [:parent_id, :work_type_id, :client_type, :qrid_id, :task_type]}
  validates :work_type_id, presence: true
  validates :client_type, presence: true, inclusion: {in: Tenant::Client::CLIENT_TYPES}

  # the conditional is to prevent the callback from running when duplicate tasks are being created
  after_create :add_default_children, unless: Proc.new { |t| t.origin_id.present? }

  strip_attributes allow_empty: true

  def display_name; 'Checklist' end

  def can_be_nested_in?(parent_id)
    parent_id.to_i == 0 || NESTING_RULES[Tenant::Task.find(parent_id).task_type].include?(self.task_type)    
  end
  
  private

  def add_default_children
    if self.task_type == 'Question'
      ['Yes', 'No', 'N/A'].each do |answer|
        child = Tenant::Task.create!(
            name: answer,
            task_type: 'Answer',
            work_type_id: self.work_type_id,
            client_type: self.client_type,
            qrid_id: self.qrid_id,
            active: self.active,
            checked: true
        )
        child.move_to_child_of(self)
      end
    end
  end
end
