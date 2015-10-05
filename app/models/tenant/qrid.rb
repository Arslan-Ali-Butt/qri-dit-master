class Tenant::Qrid < ActiveRecord::Base
  #include Statable

  has_paper_trail
  
  belongs_to :site
  belongs_to :work_type

  has_and_belongs_to_many :permatasks
  has_many :tasks, dependent: :delete_all
  has_many :assignments, dependent: :destroy
  has_many :reports, dependent: :destroy

  has_many :photos, class_name: 'Tenant::QridPhoto', dependent: :destroy

  attr_accessor :default_task_ids
  attr_accessor :next_assignment

  validates :site, presence: true
  validates :work_type, presence: true
  validates :name, presence: true, uniqueness: {scope: [:site_id, :work_type_id]}

  STATUSES = ['Active', 'Deleted']
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  before_create :copy_site_status!
  after_create :duplicate_all_tasks!  
  before_update :update_checked_default_tasks
  #after_save :rebuild_sphinx_index

  def display_name; 'QRID' end

  def qrid_name; "#{self.name} - #{self.site.name}" end

  def self.active; where(status: 'Active') end

  def duplicate_tasks(tasks, connection = :attached)
    ActiveRecord::Base.transaction do
      mapped_ids = {}
      tasks.each do |task|
        dup_task = Tenant::Task.create!(
            name: task.name,
            task_type: task.task_type,
            work_type_id: task.work_type_id,
            client_type: task.client_type,
            active: task.active,
            checked:
            case connection
              when :attached
                task.checked
              when :detached
                false
            end,
            origin_id: task.id,
            qrid_id: self.id,
            parent_id: mapped_ids[task.parent_id],
            position: task.position
        )
        mapped_ids[task.id] = dup_task.id
      end
    end
  end

  def duplicate_all_tasks!
    tasks = Tenant::Task.join_recursive { |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)
      }
                .where(qrid_id: nil)
                .where(origin_id: nil)
                .where(work_type_id: self.work_type_id)
                .where(client_type: self.site.owner.client_type)
    self.duplicate_tasks(tasks)

  end

  def note_meta_data
    self.staff = current_user
  end

  def self.generate_next_assignment_timestamps
    where(next_assignment_timestamp_stale: true).each do |qrid|
      options = {qrid_id: qrid.id, status: ['Open', 'In Progress']}
      assignment = Tenant::Assignment.list(Time.now, Time.now + 30.day, options).first

      timestamp = assignment ? assignment.start_at.to_i : 10000000

      qrid.update(next_assignment_timestamp: timestamp, next_assignment_timestamp_stale: false)
    end
  end
  
  private

  def copy_site_status!
    self.status = self.site.status
  end
  
  def update_checked_default_tasks    
    self.tasks.join_recursive { |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)
      }.where.not(origin_id: nil).each do |task|
      task.update_columns(checked: false) if task.checked && (self.default_task_ids.nil? || !self.default_task_ids.include?(task.id.to_s))
      task.update_columns(checked: true) if !task.checked && (!self.default_task_ids.nil? && self.default_task_ids.include?(task.id.to_s))
    end if !self.default_task_ids.nil? # && self.default_task_ids.changed?
  end

  def rebuild_sphinx_index
    db = Apartment::Tenant.current_tenant
    ThinkingSphinx::RealTime.callback_for("qrid_#{db}".to_sym)
  end
end
