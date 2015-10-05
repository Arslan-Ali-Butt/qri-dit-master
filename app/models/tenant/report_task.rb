class Tenant::ReportTask < ActiveRecord::Base
  belongs_to :report
  has_many :solutions, class_name: 'Tenant::ReportSolution', dependent: :destroy

  validates :report_id, presence: true
  validates :task_id, presence: true
  validates :task_type, presence: true, inclusion: {in: Sortable::TYPES}
  validates :name, presence: true
  validates :description, presence: true

  strip_attributes allow_empty: true
end
