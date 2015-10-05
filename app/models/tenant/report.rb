class Tenant::Report < ActiveRecord::Base
  #include Statable

  has_paper_trail
  
  belongs_to :assignment
  belongs_to :qrid
  belongs_to :reporter, class_name: 'Tenant::Staff', foreign_key: :reporter_id

  has_many :photos, class_name: 'Tenant::ReportPhoto', dependent: :destroy
  has_many :report_tasks, dependent: :destroy
  has_many :solutions, class_name: 'Tenant::ReportSolution'
  has_many :unread_notes, -> { where unread_by_manager: true }, class_name: 'Tenant::ReportNote'
  has_many :notes, class_name: 'Tenant::ReportNote', dependent: :destroy


  STATUSES = ['New', 'Flagged', 'In discussion', 'Closed']

  validates :assignment_id, presence: true
  validates :started_at, presence: true
  validates_associated :photos

  attr_accessor :qrid_cache_timestamp

  strip_attributes allow_empty: true

  before_create do
    self.qrid_id      = self.assignment.qrid_id
    self.reporter_id  = self.assignment.assignee_id
  end

  before_save :set_logged_time

  after_save :set_reporter_time_data, if: Proc.new { |r| r.completed_at_was.nil? and r.completed_at.present? }

  def display_name; 'Report' end

  def submit(params)
    self.submitted_at = Time.now
    self.completed_at = params[:completed_at_i].present? ? Time.at(params[:completed_at_i].to_i) : Time.now

    self.unread_by_manager = true
    self.assignment.update_columns(status: 'Done')
    self.comments = params[:general_comments].present? ? params[:general_comments] : ""
    self.is_permatask_report = params[:is_permatask_report] if params[:is_permatask_report].present?

    if self.assignment.try(:permatask)
      tasks = Tenant::Permatask.join_recursive do |query|
        query
            .start_with(parent_id: nil)
            .connect_by(id: :parent_id)
            .order_siblings(position: :asc)
       end
    else
      tasks = Tenant::Task.join_recursive { |query|
        query
            .start_with(parent_id: nil)
            .connect_by(id: :parent_id)
            .order_siblings(position: :asc)

        }.where(qrid_id: self.qrid_id)
    end

    tasks.each do |node|
      node = node.version_at(Time.at(self.qrid_cache_timestamp)) if self.qrid_cache_timestamp.present?

      s_id = node.id.to_s
      if params[:questions].present? && params[:questions].keys.include?(s_id)
        self.report_tasks.create!(
            task_id: node.id,
            task_type: node.task_type,
            name: node.name,
            description: params[:questions][s_id]
        )
        self.flagged = true if params[:questions][s_id] == 'Yes'
      end
      if params[:comments].present? && params[:comments].keys.include?(s_id) && params[:comments][s_id].present?
        comment = params[:comments][s_id].gsub(/<(.*?)>/, '')
        self.report_tasks.create!(
            task_id: node.id,
            task_type: node.task_type,
            name: node.name,
            description: comment
        )
      end
      if params[:instructions].present? && params[:instructions].keys.include?(s_id) && params[:instructions][s_id].present?
        p = (self.is_permatask_report ? Tenant::Permatask.find(s_id).try(:parent) : Tenant::Task.find(s_id).try(:parent))
        p_id = (p.try(:task_type) == 'Group' ? p.try(:id) : p.try(:parent).try(:id))
        if (p.try(:task_type) == 'Group') || (p.try(:name) == params[:questions][p_id.to_s])
          self.report_tasks.create!(
              task_id: node.id,
              task_type: node.task_type,
              name: node.name,
              description: params[:instructions][s_id]
          )
        end
      end
    end

    if params[:photos].present?
      params[:photos].each do |task_id, photos|

        photos.each do |photo_url|
          self.photos.new(task_id: task_id, photo_url: photo_url)
        end
      end
    end

    self.save

    Tenant::Staff.by_role(['Manager', 'Admin']).each do |recipient|
      Tenant::Mailer.report_notification(self, recipient).deliver
    end

    self.notify_reporter
  end

  def notify_reporter
    if !reporter.ios_auth_tokens.nil? and reporter.ios_auth_tokens.count > 0
      ZeroPush.notify(device_tokens: reporter.ios_auth_tokens, alert: "Your report for #{qrid.name} has been submitted!")
    end
  end

  def client_notes
    notes = Tenant::ReportNote.by_author_role('Client').where(report: self)
  end

  def num_client_notes
    Tenant::ReportNote.by_author_role('Client').where(report: self).count
  end

  def set_logged_time
    self.logged = ((self.completed_at.present? and self.started_at.present?) ? self.completed_at - self.started_at : 0)
  end

  def set_reporter_time_data
    resource = self

    if self.completed_at_was.nil? and self.completed_at.present?
      self.reporter.last_report_at = self.completed_at
    else
      last_report = Tenant::Report.where(reporter_id: self.reporter.id).where.not(completed_at: nil).order(completed_at: :desc).first
      last_report ? self.reporter.last_report_at = last_report.completed_at : self.reporter.last_report_at = nil
    end

    reports_this_week = Tenant::Report.where(reporter_id: self.reporter.id).where(completed_at: Time.now.all_week)
    time_this_week = 0
    reports_this_week.each do |rep|
      time_this_week += rep.completed_at - rep.started_at
    end

    self.reporter.time_this_week = time_this_week.to_i

    reports_this_month = Tenant::Report.where(reporter_id: self.reporter.id).where(completed_at: Time.now.all_month)
    time_this_month = 0
    reports_this_month.each do |rep|
      time_this_month += rep.completed_at - rep.started_at
    end

    self.reporter.time_this_month = time_this_month.to_i
    self.reporter.save!
  end
end
