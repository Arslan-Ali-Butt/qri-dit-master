class Tenant::ReportSolution < ActiveRecord::Base
  belongs_to :report
  belongs_to :report_task

  validates :report_id, presence: true
  validates :report_task_id, presence: true
  validates :description, presence: true

  strip_attributes allow_empty: true

  def display_name; 'Solution' end

  def collection_id; self.report_task_id end
end
