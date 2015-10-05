module Tenant
  module Assignments
    extend ActiveSupport::Concern

    included do
      helper_method :process_index_action

      private
      def set_resource
        @resource = (@assignee_id ? Tenant::Assignment.where(assignee_id: @assignee_id) : Tenant::Assignment).find(params[:id])
      end

      def resource_params
        ret = params.require(:tenant_assignment).permit(:start_at, :end_at, :assignee_id, :qrid_id, :comment, 
          :recurrence_action, :recurrence_action_type, :recurrence, :recurring_until_at, :overrided_start_at, :confirmed)
        ret[:recurrence] = nil if ret[:recurrence].blank?
        ret[:assignee_id] = @assignee_id if @assignee_id
        ret[:unread] = true
        ret
      end
    end

    def process_index_action
      respond_to do |format|
        yield(format) if block_given? # do any custom formatting here

        format.json do
          if @assignee_id
            reporter_view = true
            tenant = Admin::Tenant.cached_find_by_host(request.host)
            if (!tenant.assignment_notification_time.nil? and tenant.assignment_notification_time > 0)
              notification_time = Time.now.beginning_of_day + tenant.assignment_notification_time.day
            end
          end

          options = {}

          @assignee_id ||= params[:assignee_id]
          options[:assignee_id] = @assignee_id if @assignee_id.present?

          @qrid_id = params[:qrid_id]
          options[:qrid_id] = @qrid_id if @qrid_id.present?

          if params[:start].present? && params[:end].present?
            from  = Time.at(params[:start].to_i)
            till  = Time.at(params[:end].to_i)
          else
            from  = Time.now - 1.day
            till  = Time.now + 1.day
          end

          @status = params[:status] || ['Open', 'In Progress', 'Done']

          options[:status] = @status if @status.present?

          if params[:confirmed].present?
            options[:confirmed] = (params[:confirmed] == "0" ? false : true)
          end

          if notification_time.present? && notification_time < till
            till = notification_time
          end
          @resources = Tenant::Assignment.list(from, till, options)
          if reporter_view
            @resources.each do |assignment|
              Tenant::Assignment.find(assignment.id).update_columns(unread: false)
            end
          end
        end
      end
    end

  end
end