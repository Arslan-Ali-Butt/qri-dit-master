class Tenant::Assignment < ActiveRecord::Base
  include IceCube

  belongs_to :assignee, class_name: 'Tenant::Staff', foreign_key: :assignee_id
  belongs_to :qrid
  has_one :report

  has_many :assignment_overrides, class_name: 'Tenant::AssignmentOverride', foreign_key: :assignment_id, dependent: :destroy, autosave: true

  STATUSES = ['Open', 'In Progress', 'Done']

  RECURRENCE = {'Daily' => 'd', 'Weekly' => 'w', 'Bi-weekly' => '2w', 'Monthly' => 'm', 'Yearly' => 'y'}

  #serialize :schedule, IceCube::Schedule

  validates_presence_of :start_at
  validates_presence_of :end_at
  validates_presence_of :assignee_id, message: 'is not selected'  
  validates_presence_of :qrid_id, message: 'is not selected'
  validates_inclusion_of :status, in: STATUSES

  validates :recurrence, inclusion: { in: RECURRENCE.values }, allow_nil: true

  strip_attributes allow_empty: true

  after_save :notify_assignee, if: Proc.new { |a| a.confirmed_was == a.confirmed }
  after_destroy :assignee_canceled

  after_save :invalidate_next_assignment_timestamp

  before_validation do
    self.status = 'Open' unless self.status
  end

  before_save do
    self.schedule = schedule.to_yaml
  end

  before_create do
    self.qrid.update(:estimated_duration => 0) if !self.qrid.estimated_duration.try(:hours)
    self.end_at = self.qrid.estimated_duration.hours.since(self.start_at) 
  end

  before_update :handle_recurrences

  # after_save :assignment_confirmed, if: Proc.new { |a| a.confirmed_was == false and a.confirmed == true }

  # def assignment_confirmed
  #   self.delay.assignment_confirmed_push_notification
  # end

  # def assignment_confirmed_push_notification
  #   ZeroPush.notify(device_tokens: [assignee.ios_auth_token], badge: '-1')
  # end

  def display_name; 'Assignment' end


  def self.list(from, till, options = {})
    assignments = joins(qrid: [:site, :work_type]).includes(:qrid).readonly(false)

    unless options.empty?
      #assignments = assignments.where(options) 

      # we need to take into account any existing overrides when filtering by qrid_id or assignee_id
      start_at_string = from.getutc.strftime "%Y-%m-%d %H:%M:%S"

      assignments = assignments.joins("LEFT OUTER JOIN #{Tenant::AssignmentOverride.table_name} ON 
        #{Tenant::AssignmentOverride.table_name}.assignment_id = #{self.table_name}.id AND 
        #{Tenant::AssignmentOverride.table_name}.start_at >= '#{start_at_string}' AND 
        #{Tenant::AssignmentOverride.table_name}.deleted != 't'")

      if !options[:confirmed].nil?
        assignments = assignments.where(confirmed: options[:confirmed])
      end

      if options[:status].present?
        assignments = assignments.where("#{self.table_name}.status IN (?)", options[:status])
      end
      

      if options[:assignee_id].present? and options[:qrid_id].present?
        assignments = assignments.where("(#{self.table_name}.assignee_id = ? AND #{self.table_name}.qrid_id = ?) OR (
          #{Tenant::AssignmentOverride.table_name}.assignee_id = ? AND #{Tenant::AssignmentOverride.table_name}.qrid_id = ?)", 
          options[:assignee_id], options[:qrid_id], options[:assignee_id], options[:qrid_id])
      elsif options[:qrid_id].present? and options[:assignee_id].nil?
        assignments = assignments.where("(#{self.table_name}.qrid_id = ?) OR (#{Tenant::AssignmentOverride.table_name}.qrid_id = ?)", 
          options[:qrid_id], options[:qrid_id])
      elsif options[:assignee_id].present? and options[:qrid_id].nil?
        assignments = assignments.where("(#{self.table_name}.assignee_id = ?) OR (#{Tenant::AssignmentOverride.table_name}.assignee_id = ?)", 
          options[:assignee_id], options[:assignee_id])
      end

        
    end

    singles     = assignments.where(recurrence: nil)
    recurrings  = assignments.where.not(recurrence: nil)

    assignments = singles.where("#{self.table_name}.start_at >= ? AND #{self.table_name}.start_at <= ?", from, till)

    recurrings.each do |assignment|

      subject_instance_anchor = nil
      subject_instance_anchor_rep = nil

      assignment.recurring_events(from, till).each do |rep|
        ocurrence_start_at = nil

        override = nil

        multiple_instance_override = nil

        dup = assignment.dup
        dup.id = assignment.id
        dup.created_at = assignment.created_at
        dup.updated_at = assignment.updated_at

        if assignment.assignment_overrides.count > 0
          rep_as_time = DateTime.parse(rep.to_time.utc.to_s).to_time.getutc.strftime "%Y-%m-%d %H:%M:%S"

          candidate_single_instance_override = assignment.assignment_overrides.where("#{Tenant::AssignmentOverride.table_name}.overrided_start_at >= '#{rep_as_time}'")
            .where(multiple_instance: false)
            .order(overrided_start_at: :asc).first

          unless candidate_single_instance_override.nil?
            if !assignment.schedule.next_occurrence(rep.to_time).nil? and 
              (assignment.schedule.next_occurrence(rep.to_time).to_time > candidate_single_instance_override.overrided_start_at)
              # this is the closest ocurrence to the start date of the override
              single_instance_override = candidate_single_instance_override    
            end
          end

          if single_instance_override.nil?
            
            candidate_multiple_instance_override = assignment.assignment_overrides
              .where("#{Tenant::AssignmentOverride.table_name}.overrided_start_at >= '#{rep_as_time}'")
              .where(multiple_instance: true)
              .order(overrided_start_at: :asc).first

            unless candidate_multiple_instance_override.nil?
              if !assignment.schedule.next_occurrence(rep.to_time).nil? and 
                (assignment.schedule.next_occurrence(rep.to_time).to_time > candidate_multiple_instance_override.overrided_start_at)
                # this is the closest ocurrence to the start date of the override
                multiple_instance_override = candidate_multiple_instance_override    
              end
            end

            # there was a multiple instance override for the time slot starting at or after datetime 'rep'
            if !multiple_instance_override.nil?
              #raise 'here????' if assignment.id == 56
              subject_instance_anchor = rep_as_time
              subject_instance_anchor_rep = rep


              ocurrence_start_at = multiple_instance_override.start_at
              
            elsif multiple_instance_override.nil? #and subject_instance_anchor.present?
              #raise 'here' if assignment.id == 56
              multiple_instance_override = assignment.assignment_overrides
                .where("#{Tenant::AssignmentOverride.table_name}.overrided_start_at >= '#{rep_as_time}' OR 
                  ( #{Tenant::AssignmentOverride.table_name}.overrided_start_at < '#{rep_as_time}' AND (
                    #{Tenant::AssignmentOverride.table_name}.recurring_until_at IS NULL OR 
                    #{Tenant::AssignmentOverride.table_name}.recurring_until_at >= '#{rep_as_time}'))")
                .where(multiple_instance: true)
                .order(start_at: :asc).first

              if !multiple_instance_override.nil? and subject_instance_anchor_rep.present?
                # we are dealing with an multiple-ocurrence override that is after the specific override but 
                # for which an exact match was known in a prior iteration
                delta = subject_instance_anchor_rep.to_time.to_i - multiple_instance_override.start_at.to_i
                ocurrence_start_at = rep.to_time.ago delta
              elsif multiple_instance_override.present? and (rep.to_time.month > assignment.start_at.to_time.month or 
                rep.to_time.year > assignment.start_at.to_time.year)

                # we are dealing with an multiple-ocurrence override that is after the specific override but 
                # for which an exact match is not known
                delta = multiple_instance_override.overrided_start_at.to_i - multiple_instance_override.start_at.to_i
                ocurrence_start_at = rep.to_time.ago delta
              else
                # no known overrides...
                
                ocurrence_start_at = assignment.start_at
              end

              
            end


            override = multiple_instance_override
          else
            # there was a single instance override for the time slot starting at datetime 'rep'
            ocurrence_start_at = single_instance_override.start_at
            override = single_instance_override
          end
        end

        if !override.nil?

          # overrides specifying a assignment deletion force us to exclude a given recurrence instance
          unless override.deleted 
            #raise ocurrence_start_at.inspect if assignment.id == 51
            dup.comment = override.comment
            dup.assignee = override.assignee
            dup.qrid = override.qrid unless override.qrid.nil?
            dup.start_at  = ocurrence_start_at
            dup.end_at    = ocurrence_start_at + (override.end_at - override.start_at)
            assignments << dup
          end
        else
          # there are no overrides so go about your merry business with regular recurrences
          dup.start_at  = rep
          dup.end_at    = rep + (assignment.end_at - assignment.start_at)
          assignments << dup
        end
        
      end
    end
    assignments.sort { |x, y| x.start_at <=> y.start_at }
  end

  def recurring_events(from, till)
    if self.recurring_until_at.present? && self.recurring_until_at < till
      till = self.recurring_until_at
    end
    return [] if self.start_at > till
    schedule.occurrences_between(from, till)
  end

  def schedule
    @schedule = read_attribute(:schedule) if @schedule.nil?

    if @schedule.nil?
      @schedule = setup_schedule(self.recurrence, self.start_at)
    else
      @schedule = Schedule.from_yaml(@schedule) unless @schedule.is_a? IceCube::Schedule
    end
    @schedule
  end

  def setup_schedule(recurrence_rule, start, until_date = nil)  
    new_schedule = Schedule.new(start.in_time_zone('UTC')) 

    case recurrence_rule
      when 'd'  then  until_date.nil? ? new_schedule.rrule(Rule.daily) : new_schedule.rrule(Rule.daily.until(until_date))
      when 'w'  
        if until_date.nil? 
          new_schedule.rrule(Rule.weekly) 
        else
          new_schedule.rrule(Rule.weekly.until(until_date))
        end
      when '2w' then  until_date.nil? ? new_schedule.rrule(Rule.weekly(2)) : new_schedule.rrule(Rule.weekly(2).until(until_date))
      when 'm'  then  until_date.nil? ? new_schedule.rrule(Rule.monthly) : new_schedule.rrule(Rule.monthly.until(until_date))
      when 'y'  then  until_date.nil? ? new_schedule.rrule(Rule.yearly) : new_schedule.rrule(Rule.yearly.until(until_date))
    end    

    new_schedule
  end

  def old_schedule
    old_schedule = setup_schedule self.recurrence_was, self.start_at_was
  end

  def start_report(started_at)
    original_assignment = prepare_to_start_report(started_at)

    if original_assignment.report
      original_assignment.report.update(started_at: started_at)
    else
      original_assignment.create_report!(started_at: started_at)
    end
    original_assignment.report.id
  end

  def prepare_to_start_report(started_at)
    dup = nil

    if self.recurrence
      # Clone assignment starting from next occurrence
      next_occurrence = self.recurring_events(self.start_at + 1.second, self.start_at + 1.year).first
      if next_occurrence
        dup = self.dup
        dup.created_at = self.created_at
        dup.updated_at = self.updated_at
        dup.start_at  = next_occurrence
        dup.end_at    = next_occurrence + (self.end_at - self.start_at)
        dup.save

        new_schedule = setup_schedule(self.recurrence, next_occurrence.to_time.utc).to_yaml unless (self.recurrence.nil? or read_attribute(:schedule).nil?)
        dup.update_columns(schedule: new_schedule)
      end
    end

    original_assignment = self.class.find(self.id)
    original_assignment.update_columns(
        recurrence: nil,
        status:   'In Progress',
        schedule: nil
    )

    unless dup.nil?
      # reassociate any future overrides with the cloned assignment now
      original_assignment.assignment_overrides.where("#{Tenant::AssignmentOverride.table_name}.overrided_start_at >= ?", Time.now).each do |override|
        override.update assignment: dup
      end
    end

    original_assignment
  end

  # add some virtual attributes to deal with the recurrence madness...
  def recurrence_action_type
    @recurrence_action_type
  end

  def recurrence_action_type=(value)
    @recurrence_action_type = value
  end

  def recurrence_action
    @recurrence_action
  end

  def recurrence_action=(value)
    @recurrence_action = value
  end

  def overrided_start_at
    @overrided_start_at
  end

  def overrided_start_at=(value)
    @overrided_start_at = value
  end
  # end of virtual attributes

  def canceled_assignment_push_notification
    if !assignee.ios_auth_tokens.nil? and assignee.ios_auth_tokens.count > 0
      ZeroPush.notify(device_tokens: assignee.ios_auth_tokens, 
            alert: "Cancelled: assignment #{self.qrid.site.name}")        
    end
  end

  private

  def notify_assignee
    if self.status == 'Open'
      assignment_notification_time = 0
      if m = Apartment::Tenant.current_tenant.match(/\d+/)
        assignment_notification_time = Admin::Tenant.find(m[0]).try(:assignment_notification_time)
      end
      if assignment_notification_time.nil? || assignment_notification_time == 0 || self.start_at < Time.now.beginning_of_day + assignment_notification_time.day
        Tenant::Mailer.assignment_notification(self).deliver 
        self.delay.new_assignment_push_notification
      end
    end
  end

  def assignee_canceled
    self.class.notify_assignee_canceled(self)
  end

  def self.notify_assignee_canceled(assignment)
    if assignment.status == 'Open'
      assignment_notification_time = 0
      if m = Apartment::Database.current_tenant.match(/\d+/)
        assignment_notification_time = Admin::Tenant.find(m[0]).try(:assignment_notification_time)
      end
      if assignment_notification_time.nil? || assignment_notification_time == 0 || assignment.start_at < Time.now.beginning_of_day + assignment_notification_time.day
        Tenant::Mailer.assignment_canceled_notification(assignment).deliver
        self.delay.canceled_assignment_push_notification
      end
    end
  end

  def new_assignment_push_notification
    if !assignee.ios_auth_tokens.nil? and assignee.ios_auth_tokens.count > 0
      ZeroPush.notify(device_tokens: assignee.ios_auth_tokens, 
            alert: "You have a new assignment for #{self.qrid.site.name}", badge: '+1')
    end
  end

  def invalidate_next_assignment_timestamp
    self.qrid.update(next_assignment_timestamp_stale: true)
  end

  def handle_recurrences
    if self.recurrence_action == 'destroy'
      new_schedule = nil

      if self.recurrence_action_type == 'this-all-following'

        unless schedule.next_occurrence.nil?
          next_ocurrence_as_time = DateTime.parse(schedule.next_occurrence.to_time.utc.to_s).to_time.getutc.strftime "%Y-%m-%d %H:%M:%S"

          # first destroy any overrides on future ocurrences 
          self.assignment_overrides.where("#{Tenant::AssignmentOverride.table_name}.start_at >= '#{next_ocurrence_as_time}'").each do |override|
            override.destroy
          end

          self.start_at = next_ocurrence_as_time # set this up so the cancellation email can be set up properly
          self.class.notify_assignee_canceled(self)
        end

        # stop the recurrence at the last occurrence, me Dr. Seuss :P
        new_schedule = setup_schedule(self.recurrence_was, self.start_at_was.utc, self.start_at.ago(1.hours).utc)
      else
        # a single instance of an event needs to be deleted

        # nuke an old override for this time slot if it exists...
        nukable_start_at = self.start_at_changed? ? self.start_at_was : self.start_at
        nukable_end_at = self.end_at_changed? ? self.end_at_was : self.end_at
        old_override = self.assignment_overrides.where(overrided_start_at: nukable_start_at).first
        old_override.destroy unless old_override.nil?

        self.assignment_overrides.build assignee: self.assignee, qrid: self.qrid, 
          start_at: self.start_at, end_at: self.end_at, overrided_start_at: self.overrided_start_at, deleted: true,
          multiple_instance: false

        self.class.notify_assignee_canceled(self)
      end

      # make sure that the delete does not change any actual data
      self.assignee_id = self.assignee_id_was
      self.qrid_id = self.qrid_id_was
      self.start_at = self.start_at_was
      self.end_at = self.end_at_was
      self.comment = self.comment_was
      self.recurrence = self.recurrence_was if self.recurrence_changed?

      #abort "#{new_schedule.to_yaml}"
      self.schedule = new_schedule.to_yaml unless new_schedule.nil?
    elsif self.recurrence_action == 'update'
      # this was an update action
      new_schedule = nil

      start_at_string = DateTime.parse(self.start_at.to_s).to_time.getutc.strftime "%Y-%m-%d %H:%M:%S"

      if self.recurrence_changed?
        # we have a lot of work to do to make sure everything will continue to work in a sensible way

        # stop the recurrence at the last occurrence, me Dr. Seuss :P
        new_schedule = setup_schedule(self.recurrence_was, self.start_at_was, self.start_at)

        #terminate_recurrence_at(old_schedule.previous_occurrence)

        # now create a new assignment with the new recurrence info
        assignment = Tenant::Assignment.create assignee: self.assignee, qrid: self.qrid, 
            start_at: self.start_at, end_at: self.end_at, recurrence: self.recurrence

        # lastly, fix any future overrides so that they fall in line with the new recurrence scheme
        self.assignment_overrides.where("#{Tenant::AssignmentOverride.table_name}.start_at <= '#{start_at_string}'").each do |override|

          @schedule = nil # reset the schedule so it gets regenerated

          override.start_at = self.schedule.next_ocurrence(override.start_at).to_time.getutc

          # IMPORTANT, associate the override with the new assignment
          override.assignment = assignment

          override.save
        end

      else
        # the other simpler attributes changed so all we need to use is overrides

        if self.recurrence_action_type == 'this-all-following'

          # nuke all old overrides on this and future ocurrences
          old_overrides = self.assignment_overrides.where("#{Tenant::AssignmentOverride.table_name}.overrided_start_at >= '#{start_at_string}'")

          old_overrides.each do |old_override|
            old_override.destroy
          end

          # multiple recurrences of an event needs to be created as an override
          # if self.day_delta.present? and self.minute_delta.present?
          #   overrided_start_at = self.start_at.advance(days: (self.day_delta * -1), minutes: (self.minute_delta * -1))
          # end

          self.assignment_overrides.build assignee: self.assignee, qrid: self.qrid, 
            start_at: self.start_at, end_at: self.end_at, comment: self.comment, 
            overrided_start_at: self.overrided_start_at, multiple_instance: true
        else  
          # a single instance of an event needs to be created as an override

          # nuke an old override for this time slot if it exists...
          nukable_start_at = self.start_at_changed? ? self.start_at_was : self.start_at
          nukable_end_at = self.end_at_changed? ? self.end_at_was : self.end_at
          old_override = self.assignment_overrides.where(overrided_start_at: nukable_start_at).first
          old_override.destroy unless old_override.nil?

          self.assignment_overrides.build assignee: self.assignee, qrid: self.qrid, 
            start_at: self.start_at, end_at: self.end_at, comment: self.comment, 
            overrided_start_at: self.overrided_start_at, multiple_instance: false
        end
      end

      # make sure the edit does not change any actual data on this assignment
      self.assignee_id = self.assignee_id_was
      self.qrid_id = self.qrid_id_was
      self.start_at = self.start_at_was
      self.end_at = self.end_at_was
      self.comment = self.comment_was
      self.recurrence = self.recurrence_was if self.recurrence_changed?

      @schedule = new_schedule.to_yaml unless new_schedule.nil?
    else
      # no recurrence related action was specifid, i.e. the assignment did not have any recurrence to begin with
    end  
    
  end
end
